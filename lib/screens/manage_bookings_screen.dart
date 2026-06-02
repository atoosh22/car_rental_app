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

  debugPrint("BOOKINGS DATA => $data");

  setState(() {
    bookings = List<Map<String, dynamic>>.from(data);
    isLoading = false;
  });
} catch (e) {
  debugPrint("LOAD BOOKINGS ERROR => $e");

  setState(() {
    isLoading = false;
  });
}


}

Future<void> updateStatus(
dynamic bookingId, String status) async {
try {
await supabase
.from('bookings')
.update({'status': status})
.eq('id', bookingId);

  await loadBookings();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:
          Text('Booking $status successfully'),
    ),
  );
} catch (e) {
  debugPrint("UPDATE ERROR => $e");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.toString()),
    ),
  );
}


}

Color getStatusColor(String status) {
switch (status.toLowerCase()) {
case 'approved':
return Colors.green;
case 'rejected':
return Colors.red;
default:
return Colors.orange;
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF5F7FA),
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
centerTitle: true,
title: const Text(
"Manage Bookings",
style: TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold,
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
fontWeight: FontWeight.w600,
),
),
)
: RefreshIndicator(
onRefresh: loadBookings,
child: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: bookings.length,
itemBuilder: (context, index) {
final booking =
bookings[index];


                  final status =
                      booking['status'] ??
                          'pending';

                  final statusColor =
                      getStatusColor(status);

                  return Container(
                    margin:
                        const EdgeInsets.only(
                            bottom: 16),
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.05),
                          blurRadius: 10,
                          offset:
                              const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  booking['carImage'] !=
                                          null
                                      ? NetworkImage(
                                          booking[
                                              'carImage'])
                                      : null,
                              child: booking[
                                          'carImage'] ==
                                      null
                                  ? const Icon(
                                      Icons
                                          .directions_car,
                                    )
                                  : null,
                            ),
                            const SizedBox(
                                width: 12),
                            Expanded(
                              child: Text(
                                booking['carName'] ??
                                    'Unknown Car',
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          "User: ${booking['user_name'] ?? ''}",
                        ),
                        Text(
                          "Email: ${booking['user_email'] ?? ''}",
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          "Car ID: ${booking['car_id'] ?? ''}",
                        ),
                        Text(
                          "User ID: ${booking['user_id'] ?? ''}",
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          "Start: ${booking['start_date'] ?? ''}",
                        ),

                        Text(
                          "End: ${booking['end_date'] ?? ''}",
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          "Total: \$${booking['total_price'] ?? 0}",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: statusColor
                                .withOpacity(
                                    0.15),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                          ),
                          child: Text(
                            status
                                .toUpperCase(),
                            style: TextStyle(
                              color:
                                  statusColor,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  ElevatedButton(
                                onPressed: () {
                                  updateStatus(
                                    booking[
                                        'id'],
                                    'approved',
                                  );
                                },
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors
                                          .green,
                                ),
                                child:
                                    const Text(
                                  "Approve",
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 10),
                            Expanded(
                              child:
                                  ElevatedButton(
                                onPressed: () {
                                  updateStatus(
                                    booking[
                                        'id'],
                                    'rejected',
                                  );
                                },
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Colors.red,
                                ),
                                child:
                                    const Text(
                                  "Reject",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
);


}
}
