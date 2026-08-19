import 'package:my_auto/features/auth/presentation/providers/confirmation_provider.dart';
import 'package:my_auto/features/auth/presentation/providers/sign_in_provider.dart';
import 'package:my_auto/features/auth/presentation/providers/sign_up_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> authProviders = [
  ChangeNotifierProvider(create: (_) => SignInProvider()),
  ChangeNotifierProvider(create: (_) => SignUpProvider()),
  ChangeNotifierProvider(create: (_) => ConfirmationProvider()),
];
