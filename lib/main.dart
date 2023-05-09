import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_examples/models/user_model.dart';
import 'package:flutter_riverpod_examples/state/user_state.dart';
import 'package:uuid/uuid.dart';

void main() {
  //1. You need to wrap the MyApp within ProviderScope. This will make the riverpod to work.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Riverpod example',
        debugShowCheckedModeBanner: false,
        home: HomePage());
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          //The consumer is a widget that will Scope
          //the UI update to whatever has inside it (in the case the state is being watched). 
          //In this case,
          //the CircularProgressIndicator is shown only when the loading variable is true.
          Consumer(
            builder: (context, ref, child) {
              //A way of listening to ONLY one of the variables of the state
              final loading = ref.watch(
                  userStateNotifierProvider.select((value) => value.loading));
              return loading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink();
            },
          ),
          ElevatedButton(
              onPressed: () {
                print('Pressed on addNewUser');
                ref
                    .read(userStateNotifierProvider.notifier)
                    .addUser(UserModel(id: const Uuid().v4(), name: ''));
              },
              child: Text('Add a new user')),
          const SizedBox(
            height: 50,
          ),
          const Expanded(child: UsersHandler())
        ],
      ),
    );
  }
}

class UsersHandler extends ConsumerWidget {
  const UsersHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watching only the users to update this part of the UI
    //The important things in this widgets are:

    //1. The watch with the select method (observing only the users list)
    //2. onChanged method to trigger the modifyUserName method (the debounce is not important)
    
    //The pattern is:
    //To access the state ref.read(userStateNotifierProvider).users, for example.
    //the read method will not observe the change in the state
    //
    //To observe the state final state = ref.watch(userStateNotifierProvider). This will update the UI
    //when any of the variables get updated (i.e the loading variable, which is not needed here). In this 
    //example we're observing only part of the state (the users list) 
    //
    //Triggering the state change:
    //you do it by ref.read(usersNotifierProvider.notifier).any_method_declared_in_the_notifier();
    //simple! reading the notifierProvider.notifier will return the Notifier class declared in the
    //state folder
    


    final users = ref.watch(userStateNotifierProvider.select((value) => value.users));
    Timer? timer;
    print(users);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: users.length,
          itemBuilder: ((context, index) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
          
                children: [
                  Text('${index + 1}.'),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 150,
                    child: Text(users[index].id.substring(0,20))),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: users[index].name)
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: users[index].name.length)),
                      onChanged: (value) {
                       
                          timer?.cancel();
                          timer = Timer(const Duration(milliseconds: 900), () {
                            print('Triggering debounced method!');
                            final id = users[index].id;
                            ref
                                .read(userStateNotifierProvider.notifier)
                                .modifyUserName(id, value);
                                timer = null;
                          });
                        
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ))),
    );
  }
}
