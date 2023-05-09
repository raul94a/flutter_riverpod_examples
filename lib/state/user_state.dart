// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod_examples/models/user_model.dart';

//1. State
class UsersState {
  bool loading;
  List<UserModel> users = [];
  UsersState({
    required this.loading,
    required this.users,
  });

 

 

  UsersState copyWith({
    bool? loading,
    List<UserModel>? users,
  }) {
    return UsersState(
      loading: loading ?? this.loading,
      users: users ?? this.users,
    );
  }
}


//2. Notifier. Class from where where're triggering the UI updating
class UsersStateNotifier extends StateNotifier<UsersState> {
  UsersStateNotifier(super.state);


  Future<void> addUser(UserModel user) async{
    state = state.copyWith(loading: true);
    await Future.delayed(const Duration(seconds: 2));
    final users = state.users;
    users.add(user);
    print(users);
    state = state.copyWith(users: users,loading: false);
    
  }

  void modifyUserName(String id, String newName){
      
      final userIndex = state.users.indexWhere((element) => element.id == id);
      if(userIndex == -1 ){
        throw Exception('User could not be found');
      }
      final users = state.users;
      final modifiedUser = users[userIndex].copyWith(name: newName);
      users[userIndex] = modifiedUser;
      state = UsersState(users: users,loading: false);

  }

}

///3. Provides the notifier to the widgets. This mean you access the state and the notifier through this
///global variable
///```dart
/// //read the users without observing
/// final users = ref.read(userStateNotifierProvider).users;
/// 
/// //read the loading boolean observing only the change in its value
/// final isLoading = ref.watch(usersStateNotifierProvider.select((state) => state.loading));
///```
final userStateNotifierProvider = StateNotifierProvider<UsersStateNotifier, UsersState>((ref){
  return UsersStateNotifier(UsersState(loading: false, users: []));
});
