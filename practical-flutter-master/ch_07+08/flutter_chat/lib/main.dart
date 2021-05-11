import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "LoginDialog.dart";
import "Model.dart" show FlutterChatModel, model;
import "Home.dart";
import "Lobby.dart";
import "Room.dart";
import "UserList.dart";
import "CreateRoom.dart";


// Note that these were moved from inside the main()-startMeUp() method after book publication to address an issue that
// occurred when a newer Flutter SDK was used.
var credentials;
var exists;


void main() {

  // Note that this was added after book publication to address an issue that occurred when a newer Flutter SDK was
  // used.
  WidgetsFlutterBinding.ensureInitialized();

  print("## main(): FlutterChat starting");

  startMeUp() async {

    // Note: We do all the work that could take some time BEFORE building the UI.

    // Discover the app's documents directory.
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    // See if the credentials file exists.
    var credentialsFile = File(join(model.docsDir.path, "credentials"));
    exists = await credentialsFile.exists();

    // If it does exist the read it in.
    if (exists) {
      credentials = await credentialsFile.readAsString();
      print("## main(): credentials = $credentials");
    }

    // Build the initial UI.
    runApp(FlutterChat());

  } /* End startMeUp(). */

  // Start the festivities!
  startMeUp();

} /* End main(). */


/// Bootstrap class (to avoid exception about internationalization).
class FlutterChat extends StatelessWidget {
  @override
  Widget build(final BuildContext context) {
    print("## FlutterChat.build()");
    return MaterialApp(home : Scaffold(body : FlutterChatMain()));
  }
}


/// Main app class.
class FlutterChatMain extends StatelessWidget {


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  @override
  Widget build(final BuildContext inContext) {

    print("## FlutterChatMain.build()");

    // Store off the context so we can launch the login dialog if needed.
    model.rootBuildContext = inContext;

    // Note that this added after book publication to address an issue that occurred when a newer Flutter SDK was used.
    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());

    return ScopedModel<FlutterChatModel>(model : model, child : ScopedModelDescendant<FlutterChatModel>(
      builder : (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return MaterialApp(initialRoute : "/",
          routes : {
            "/Lobby" : (screenContext) => Lobby(),
            "/Room" : (screenContext) => Room(),
            "/UserList" : (screenContext) => UserList(),
            "/CreateRoom" : (screenContext) => CreateRoom()
          },
          home : Home()
        );
      }
    ));

  } /* End build(). */


  // If the credential file exists then call the server to validate the user.  Note that there's an edge case where
  // if a user registers, then the server restarts, and ANOTHER user registers with this one's userName, and then
  // this user tries to validate, it will fail because the password (presumably!) won't match.  In that case,
  // the code in validateWithStoredCredentials() will delete the credentials file and alert the user to this
  // situation.  Upon app restart, they'll be prompted for new credentials.
  // Note that this was moved from inside the main()->startMeUp() method after book publication to address an issue
  // that occurred when a newer Flutter SDK was used.  This also introduces the addPostFrameCallback() technique
  // to have this code execute after build() completes, which originally wasn't necessary.
  Future<void> executeAfterBuild() async {

    if (exists) {

      print("## main(): Credential file exists, calling server with stored credentials");

      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);

    // If it DOESN'T exist then show the login dialog.
    } else {

      print("## main(): Credential file does NOT exist, prompting for credentials");

      await showDialog(context : model.rootBuildContext, barrierDismissible : false,
        builder : (BuildContext inDialogContext) {
          return LoginDialog();
        }
      );

    }

  } /* executeAfterBuild(). */


} /* End class. */
