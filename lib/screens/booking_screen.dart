import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final supabase = Supabase.instance.client;

  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final data = await supabase
          .from('bookings')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;

      case 'approved':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : bookings.isEmpty
          ? const Center(
        child: Text(
          "No bookings found",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    booking['carImage'] ?? '',
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    errorBuilder: (c, e, s) {
                      return Container(
                        height: 210,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 70,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // NAME + PRICE
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [

                          Expanded(
                            child: Text(
                              booking['carName'] ??
                                  'Unknown Car',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            "\$${booking['total_price']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // DATE BOX
                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                          BorderRadius.circular(14),
                        ),

                        child: Column(
                          children: [

                            Row(
                              children: [

                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue,
                                  size: 22,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    "Start Date",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Text(
                                  booking['start_date']
                                      ?.toString()
                                      .split('T')[0] ??
                                      '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [

                                const Icon(
                                  Icons.event,
                                  color: Colors.red,
                                  size: 22,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    "End Date",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                ),

                                Text(
                                  booking['end_date']
                                      ?.toString()
                                      .split('T')[0] ??
                                      '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // STATUS
                      Row(
                        children: [

                          const Text(
                            "Status:",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),

                            decoration: BoxDecoration(
                              color: getStatusColor(
                                booking['status'] ?? '',
                              ).withOpacity(0.12),

                              borderRadius:
                              BorderRadius.circular(30),
                            ),

                            child: Text(
                              booking['status']
                                  ?.toString()
                                  .toUpperCase() ??
                                  '',
                              style: TextStyle(
                                fontSize: 13,
                                color: getStatusColor(
                                  booking['status'] ?? '',
                                ),
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}