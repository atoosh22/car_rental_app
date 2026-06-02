import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final data = await supabase
          .from('profiles')
          .select('id,name,email,role,created_at');

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRole(
    String userId,
    String role,
  ) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);

      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Role Updated"),
        ),
      );
    } catch (e) {
      debugPrint("ROLE ERROR: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

      await loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User Deleted"),
        ),
      );
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Manage Users"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : users.isEmpty
              ? const Center(
                  child: Text(
                    "No Users Found",
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      final id =
                          user['id']?.toString() ?? '';

                      final name =
                          user['name']?.toString() ??
                              'Unknown User';

                      final email =
                          user['email']?.toString() ??
                              'No Email';

                      final role =
                          user['role']?.toString().toLowerCase() ==
                                  'admin'
                              ? 'admin'
                              : 'user';

                      return Card(
                        elevation: 3,
                        margin:
                            const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              name.isNotEmpty
                                  ? name[0]
                                      .toUpperCase()
                                  : 'U',
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(email),
                          trailing: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              DropdownButton<String>(
                                value: role,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child:
                                        Text('Admin'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'user',
                                    child:
                                        Text('User'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value !=
                                      null) {
                                    updateRole(
                                      id,
                                      value,
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context:
                                        context,
                                    builder: (_) =>
                                        AlertDialog(
                                      title:
                                          const Text(
                                        "Delete User",
                                      ),
                                      content:
                                          const Text(
                                        "Are you sure?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                                context);
                                          },
                                          child:
                                              const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () async {
                                            Navigator.pop(
                                                context);

                                            await deleteUser(
                                              id,
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Delete",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}