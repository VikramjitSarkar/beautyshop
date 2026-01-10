import { Subscription } from "../model/Subscription.js";
import { Vendor } from "../model/Vendor.js";
import { Plan } from "../model/Plan.js";
import Stripe from "stripe";
import { Payment } from '../model/Payment.js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create Subscription
export const createSubscription = async (req, res, next) => {
  try {
    const { vendorId, planId, paymentMethodId, customerId } = req.body;

    const vendor = await Vendor.findById(vendorId);
    const plan = await Plan.findById(planId);
    if (!vendor || !plan) {
      return res.status(404).json({
        status: "error",
        message: "Vendor or plan not found"
      });
    }

                                
    const existingSub = await Subscription.findOne({ vendorId, status: "active" }); 
    if (existingSub) {
      // Cancel the existing subscription and allow upgrade
      existingSub.status = "canceled";
      existingSub.endDate = new Date();
      await existingSub.save();
      console.log(`✅ Canceled existing subscription: ${existingSub._id}`);
    }

    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    // strpie charigngn 
    const paymentIntent = await stripe.paymentIntents.create({
      customer: customerId,
      amount: Math.round(plan.price * 100),
      currency: "usd",
      payment_method: paymentMethodId,
      confirm: true,
      description: `Subscription for plan ${planId} by vendor ${vendorId}`,
      automatic_payment_methods: {
        enabled: true,
        allow_redirects: 'never'
      }
    });

    // save in dba fter success
    const startDate = new Date();
    const endDate = new Date(
      startDate.getTime() + plan.durationInDays * 24 * 60 * 60 * 1000
    );

    const subscription = await Subscription.create({
      vendorId,
      planId,
      price: plan.price,
      stripePaymentId: paymentIntent.id,
      status: "active",
      startDate,
      endDate,
    });
     // record payment
      await Payment.create({
        vendor:    vendorId,
        amount:    plan.price,
        method:    'card',
        type:      'subscription',
        reference: paymentIntent.id,
        status:    'completed'
      });
    //  vendor listing plan to padi 
    await Vendor.findByIdAndUpdate(vendorId, { listingPlan: "paid" });

    res.status(201).json({ status: "success", data: subscription });
  } catch (error) {
    next(error);
  }
};




// Get All Subscriptions
export const getSubscriptions = async (req, res, next) => {
  try {
    const { vendorId } = req.query;

    const query = { status: "active" };
    if (vendorId) query.vendorId = vendorId;

    const subs = await Subscription.find(query)
      .populate("vendorId")
      .populate("planId");

    res.json({ status: "success", data: subs });
  } catch (error) {
    next(error);
  }
};

// Get One Subscription
export const getSubscriptionById = async (req, res, next) => {
  try {
    const sub = await Subscription.findById(req.params.id)
      .populate("vendorId")
      .populate("planId");

    if (!sub) {
      return res.status(404).json({ status: "error", message: "Subscription not found" });
    }

    res.json({ status: "success", data: sub });
  } catch (error) {
    next(error);
  }
};

// Cancel Subscription
export const cancelSubscription = async (req, res, next) => {
  try {
    const sub = await Subscription.findById(req.params.id);
    
    if (!sub) {
      return res.status(404).json({
        status: "error",
        message: "Subscription not found"
      });
    }

    // Only cancel Stripe subscription if it exists (not for referral code subscriptions)
    if (sub.stripeSubscriptionId) {
      await stripe.subscriptions.del(sub.stripeSubscriptionId);
    }
    
    sub.status = "canceled";
    sub.endDate = new Date();
    await sub.save();
    
    // Update vendor's listing plan to free
    await Vendor.findByIdAndUpdate(sub.vendorId, { listingPlan: "free" });
    
    res.json({
      status: "success",
      message: "Subscription canceled",
      data: sub,
    });
  } catch (error) {
    next(error);
  }
};

// Update Subscription (e.g., upgrade plan)
export const updateSubscription = async (req, res, next) => {
  try {
    const { newPlanId } = req.body;
    const sub = await Subscription.findById(req.params.id);

    const updatedSub = await stripe.subscriptions.update(
      sub.stripeSubscriptionId,
      {
        items: [{ id: sub.stripeSubscriptionId, price: newPlanId }],
      }
    );

    sub.planId = newPlanId;
    await sub.save();

    res.json({ status: "success", message: "Subscription updated", data: sub });
  } catch (error) {
    next(error);
  }
};

export const renewSubscription = async (req, res, next) => {
  try {
    const { vendorId, planId, paymentMethodId } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor)
      return res
        .status(404)
        .json({ status: "error", message: "Vendor not found" });

    const plan = await Plan.findById(planId);
    if (!plan || !plan.stripePriceId) {
      return res.status(400).json({
        status: "error",
        message: "Invalid plan or missing stripePriceId",
      });
    }

    // Create or reuse Stripe customer
    let customer;
    if (!vendor.stripeCustomerId) {
      const createdCustomer = await stripe.customers.create({
        email: vendor.email,
        payment_method: paymentMethodId,
      });
      vendor.stripeCustomerId = createdCustomer.id;
      await vendor.save();
      customer = createdCustomer;
    } else {
      customer = await stripe.customers.retrieve(vendor.stripeCustomerId);
    }

    // Create new Stripe subscription
    const subscription = await stripe.subscriptions.create({
      customer: customer.id,
      items: [{ price: plan.stripePriceId }],
      payment_settings: {
        payment_method_types: ["card"],
        payment_method_options: {
          card: { request_three_d_secure: "automatic" },
        },
        payment_method: paymentMethodId,
        save_default_payment_method: "on_subscription",
      },
      expand: ["latest_invoice.payment_intent"],
    });
        await Payment.create({
        vendor:    vendorId,
        amount:    plan.price,
        method:    'card',
        type:      'subscription',
        reference: paymentIntent.id,
        status:    'completed'
      });
    const startDate = new Date(subscription.start_date * 1000);
    const endDate = new Date(subscription.current_period_end * 1000);

    // Save new subscription in DB
    const newSub = await Subscription.create({
      vendorId,
      planId,
      stripeSubscriptionId: subscription.id,
      status: subscription.status,
      startDate,
      endDate,
    });

    res.status(201).json({ status: "success", data: newSub });
  } catch (error) {
    next(error);
  }
};
