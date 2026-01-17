# Stripe SDK - Prevent Stripe classes from being stripped or obfuscated
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Optional: Suppress specific push provisioning warnings
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# Preserve annotations
-keepattributes *Annotation*

# Kotlin
-dontwarn kotlin.**
-keep class kotlin.** { *; }

# Google Sign-In / Credential Manager
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.libraries.identity.** { *; }
-keep class androidx.credentials.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn androidx.credentials.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**
