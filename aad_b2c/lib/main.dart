import 'package:aad_b2c_webview/aad_b2c_webview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

onRedirect(BuildContext context) {
  Navigator.pushNamed(context, '/');
}

class MyApp extends StatelessWidget {
  static const authFlowUrl = '<user_flow_endpoint>';
  static const redirectUrl = '<redirect_url>';

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF2F56D2),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontFamily: 'UberMove',
          ),
          bodyText1: TextStyle(
            color: Color(0xFF8A8A8A),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            fontFamily: 'UberMoveText',
          ),
          headline2: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontFamily: 'UberMove',
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the Create Account widget.

        '/': (context) => const LoginPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? jwtToken;
  String? refreshToken;

  @override
  Widget build(BuildContext context) {
    const aadB2CClientID = "<clientId>";
    const aadB2CRedirectURL = "<azure_active_directory_url_redirect>";
    const aadB2CUserFlowName = "B2C_<name_of_userflow>";
    const aadB2CScopes = ['openid', 'offline_access'];
    const aadB2CUserAuthFlow =
        "https://<tenant-name>.b2clogin.com/<tenant-name>.onmicrosoft.com"; // https://login.microsoftonline.com/<azureTenantId>/oauth2/v2.0/token/
    const aadB2TenantName = "<tenant-name>";

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Login flow
            ADLoginButton(
              userFlowUrl: aadB2CUserAuthFlow,
              clientId: aadB2CClientID,
              userFlowName: aadB2CUserFlowName,
              redirectUrl: aadB2CRedirectURL,
              context: context,
              scopes: aadB2CScopes,
              onAnyTokenRetrieved: (TokenEntity anyToken) {},
              onIDToken: (TokenEntity token) {
                jwtToken = token.value;
              },
              onAccessToken: (TokenEntity token) {},
              onRefreshToken: (TokenEntity token) {
                refreshToken = token.value;
              },
              onRedirect: (context) => {
                Navigator.of(context).pop(),
              },
              loadingReplacement: Builder(builder: (context) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Loading...'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            /// Refresh token
            TextButton(
              onPressed: () async {
                if (refreshToken != null) {
                  AzureTokenResponseEntity? response =
                      await ClientAuthentication.refreshTokens(
                    refreshToken: refreshToken!,
                    tenant: aadB2TenantName,
                    policy: aadB2CUserAuthFlow,
                    clientId: aadB2CClientID,
                  );
                  if (response != null) {
                    refreshToken = response.refreshToken;
                    jwtToken = response.idToken;
                  }
                }
              },
              child: const Text("Refresh my token"),
            )
          ],
        ),
      ),
    );
  }
}
