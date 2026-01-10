import 'package:beautician_app/constants/globals.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:beautician_app/controllers/vendors/dashboard/earningsController.dart';

class EarningsTabScreen extends StatefulWidget {
  const EarningsTabScreen({super.key});

  @override
  State<EarningsTabScreen> createState() => _EarningsTabScreenState();
}

class _EarningsTabScreenState extends State<EarningsTabScreen> {
  final EarningsController controller = Get.put(EarningsController());
  String selectedPeriod = 'all';

  @override
  void initState() {
    super.initState();
    controller.fetchEarnings(GlobalsVariables.vendorId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Period Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('All Time', 'all'),
                  _buildPeriodChip('Today', 'today'),
                  _buildPeriodChip('This Week', 'week'),
                  _buildPeriodChip('This Month', 'month'),
                  _buildPeriodChip('This Year', 'year'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Summary Cards
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final data = controller.earningsData.value;
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Earnings',
                          '\$${data['totalEarnings'] ?? 0}',
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Bookings',
                          '${data['totalBookings'] ?? 0}',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Avg/Booking',
                          '\$${data['averagePerBooking'] ?? 0}',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Subscriptions',
                          '\$${controller.subscriptionTotal.value}',
                          Icons.subscriptions,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 20),
            
            // Tabs for Earnings, Cancelled, Subscriptions
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    TabBar(
                      labelColor: kPrimaryColor,
                      unselectedLabelColor: kGreyColor,
                      indicatorColor: kPrimaryColor,
                      tabs: const [
                        Tab(text: 'Earnings'),
                        Tab(text: 'Cancelled'),
                        Tab(text: 'Subscriptions'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildEarningsTab(),
                          _buildCancelledTab(),
                          _buildSubscriptionsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = selectedPeriod == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedPeriod = value;
            });
            controller.fetchEarnings(GlobalsVariables.vendorId!, period: value);
          }
        },
        selectedColor: kPrimaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? kPrimaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return Obx(() {
      final breakdown = controller.earningsData.value['breakdown'] as List? ?? [];
      
      if (breakdown.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.money_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No earnings yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16),
        itemCount: breakdown.length,
        itemBuilder: (context, index) {
          final item = breakdown[index];
          return _buildEarningItem(item);
        },
      );
    });
  }

  Widget _buildEarningItem(Map<String, dynamic> item) {
    final services = item['services'] as List? ?? [];
    final totalAmount = item['totalAmount'] ?? 0;
    final userName = item['userName'] ?? 'Unknown User';
    final createdAt = DateTime.tryParse(item['createdAt'] ?? '');
    final locationType = item['serviceLocationType'] ?? 'salon';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: item['userImage'] != null && item['userImage'].toString().isNotEmpty
                      ? NetworkImage(item['userImage'])
                      : null,
                  child: item['userImage'] == null || item['userImage'].toString().isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            locationType == 'home' ? Icons.home : Icons.store,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationType == 'home' ? 'Home Service' : 'At Salon',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$totalAmount',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        DateFormat('MMM dd, yyyy').format(createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'Services:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...services.map((service) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '• ${service['name'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      ),
                    ),
                    Text(
                      '\$${service['charge'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledTab() {
    return Obx(() {
      final cancelled = controller.cancelledBookings.value;
      
      if (cancelled.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No cancelled bookings', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16),
        itemCount: cancelled.length,
        itemBuilder: (context, index) {
          final item = cancelled[index];
          return _buildCancelledItem(item);
        },
      );
    });
  }

  Widget _buildCancelledItem(Map<String, dynamic> item) {
    final services = item['services'] as List? ?? [];
    final totalAmount = item['totalCharges'] ?? 0;
    final userName = item['userName'] ?? item['user']?['userName'] ?? 'Unknown User';
    final cancelledAt = DateTime.tryParse(item['cancelledAt'] ?? '');
    final reason = item['cancellationReason'] ?? 'No reason provided';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Lost: \$$totalAmount',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (cancelledAt != null)
                  Text(
                    DateFormat('MMM dd, yyyy').format(cancelledAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: $reason',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (services.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(
                'Services:',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...services.map((service) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• ${service['serviceName'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsTab() {
    return Obx(() {
      final subscriptions = controller.subscriptions.value;
      
      if (subscriptions.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No subscription payments', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          final item = subscriptions[index];
          return _buildSubscriptionItem(item);
        },
      );
    });
  }

  Widget _buildSubscriptionItem(Map<String, dynamic> item) {
    final price = item['price'] ?? 0;
    final status = item['status'] ?? 'unknown';
    final startDate = DateTime.tryParse(item['startDate'] ?? '');
    final endDate = DateTime.tryParse(item['endDate'] ?? '');
    final planName = item['plan']?['name'] ?? 'Unknown Plan';
    
    Color statusColor = Colors.grey;
    if (status == 'active') statusColor = Colors.green;
    if (status == 'expired') statusColor = Colors.orange;
    if (status == 'canceled') statusColor = Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.subscriptions, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$$price',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    Text(
                      startDate != null 
                          ? DateFormat('MMM dd, yyyy').format(startDate)
                          : 'N/A',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'End Date',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    Text(
                      endDate != null 
                          ? DateFormat('MMM dd, yyyy').format(endDate)
                          : 'N/A',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
