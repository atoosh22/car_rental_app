import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() =>
      _ManageBookingsScreenState();
}

class _ManageBookingsScreenState
    extends State<ManageBookingsScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await supabase
          .from('bookings')
          .select('''
            id,
            user_id,
            car_id,
            start_date,
            end_date,
            total_price,
            status,
            carName,
            carImage,
            user_name,
            user_email,
            created_at
          ''')
          .order('created_at', ascending: false);

      setState(() {
        bookings = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateStatus(
      dynamic bookingId,
      String status,
      ) async {
    try {
      await supabase
          .from('bookings')
          .update({
        'status': status,
      })
          .eq('id', bookingId);

      await loadBookings();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
          status == "approved"
              ? Colors.green
              : Colors.red,
          content: Text(
            "Booking $status successfully",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Manage Bookings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme:
        const IconThemeData(color: Colors.black),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : bookings.isEmpty
          ? const Center(
        child: Text(
          "No Bookings Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: loadBookings,
        child: ListView.builder(
          padding:
          const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder:
              (context, index) {
            final booking =
            bookings[index];

            final status =
                booking['status'] ??
                    "pending";

            final statusColor =
            getStatusColor(
                status);

            return Container(
              margin:
              const EdgeInsets.only(
                bottom: 20,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                    25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                        0.08),
                    blurRadius: 15,
                    offset:
                    const Offset(
                        0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [

                  /// CAR IMAGE
                  ClipRRect(
                    borderRadius:
                    const BorderRadius
                        .vertical(
                      top:
                      Radius.circular(
                          25),
                    ),
                    child: booking[
                    'carImage'] !=
                        null
                        ? Image.network(
                      booking[
                      'carImage'],
                      height: 220,
                      width: double
                          .infinity,
                      fit: BoxFit
                          .cover,
                    )
                        : Container(
                      height: 220,
                      color: Colors
                          .grey
                          .shade300,
                      child:
                      const Center(
                        child: Icon(
                          Icons
                              .directions_car,
                          size: 80,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                    const EdgeInsets
                        .all(18),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking['carName'] ??
                                    "Unknown Car",
                                style:
                                const TextStyle(
                                  fontSize:
                                  22,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),

                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                14,
                                vertical:
                                7,
                              ),
                              decoration:
                              BoxDecoration(
                                color: statusColor
                                    .withOpacity(
                                    .15),
                                borderRadius:
                                BorderRadius.circular(
                                    30),
                              ),
                              child: Text(
                                status
                                    .toUpperCase(),
                                style:
                                TextStyle(
                                  color:
                                  statusColor,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 15),

                        infoRow(
                          Icons.person,
                          "Customer",
                          booking['user_name'] ??
                              "",
                        ),

                        const SizedBox(
                            height: 10),

                        infoRow(
                          Icons.email,
                          "Email",
                          booking['user_email'] ??
                              "",
                        ),

                        const SizedBox(
                            height: 10),

                        infoRow(
                          Icons.calendar_month,
                          "Start Date",
                          booking['start_date']
                              .toString(),
                        ),

                        const SizedBox(
                            height: 10),

                        infoRow(
                          Icons.event,
                          "End Date",
                          booking['end_date']
                              .toString(),
                        ),

                        const SizedBox(
                            height: 15),

                        Container(
                          width: double
                              .infinity,
                          padding:
                          const EdgeInsets
                              .all(14),
                          decoration:
                          BoxDecoration(
                            color: Colors
                                .blue
                                .shade50,
                            borderRadius:
                            BorderRadius
                                .circular(
                                15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .payments,
                                color: Colors
                                    .blue,
                              ),
                              const SizedBox(
                                  width:
                                  10),
                              Text(
                                "\$${booking['total_price'] ?? 0}",
                                style:
                                const TextStyle(
                                  fontSize:
                                  20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        Row(
                          children: [
                            Expanded(
                              child:
                              ElevatedButton
                                  .icon(
                                onPressed:
                                    () {
                                  updateStatus(
                                    booking[
                                    'id'],
                                    'approved',
                                  );
                                },
                                icon:
                                const Icon(
                                  Icons
                                      .check,
                                  color: Colors
                                      .white,
                                ),
                                label:
                                const Text(
                                  "Approve",
                                ),
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors
                                      .green,
                                  foregroundColor:
                                  Colors
                                      .white,
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical:
                                    14,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        15),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width: 10),

                            Expanded(
                              child:
                              ElevatedButton
                                  .icon(
                                onPressed:
                                    () {
                                  updateStatus(
                                    booking[
                                    'id'],
                                    'rejected',
                                  );
                                },
                                icon:
                                const Icon(
                                  Icons
                                      .close,
                                  color: Colors
                                      .white,
                                ),
                                label:
                                const Text(
                                  "Reject",
                                ),
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors.red,
                                  foregroundColor:
                                  Colors
                                      .white,
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical:
                                    14,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        15),
                                  ),
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
      ),
    );
  }

  Widget infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}