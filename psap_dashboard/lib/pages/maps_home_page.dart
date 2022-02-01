import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:psap_dashboard/pages/maps.dart';
import 'package:psap_dashboard/pages/signaling.dart';
import 'package:psap_dashboard/widget/navigation_drawer_widget.dart';
import 'call_control_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as FbDb;

class MapsHomePage extends StatefulWidget {
  final name;

  const MapsHomePage({Key? key, required this.name}) : super(key: key);

  @override
  State<MapsHomePage> createState() => _MapsHomePageState();
}

class _MapsHomePageState extends State<MapsHomePage> {
  var timeWaited = "0";
  String? timeWaitedString = ' ';
  // video streaming
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String name = '';

  void getUSer() async{
    Future.delayed(Duration.zero,()
    {
      setState(() {
        name = widget.name;
      });
    });
  }

  void getTimeWaited(String? phone) async{
  Future.delayed(Duration.zero,(){

  WidgetsFlutterBinding.ensureInitialized();
  FbDb.DatabaseReference ref = FbDb.FirebaseDatabase.instance.ref();
    ref
        .child('sensors')
        .child(phone!)
        .child('Timer')
        .onValue
        .listen((event) async {
      timeWaited = event.snapshot.value.toString();
      setState(() {
        timeWaitedString = timeWaited;
      });
    });
  });
  }


  @override
  void initState() {
    getUSer();
    // Video streaming
    _remoteRenderer.initialize();
    _localRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    signaling.openUserMedia(_localRenderer, _remoteRenderer);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() async {
    // clean video streaming
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    // clear users
    super.dispose();
  }

  final Stream<QuerySnapshot> Waiting =
      FirebaseFirestore.instance.collection('SOSEmergencies').snapshots();
  @override
  Widget build(BuildContext context) => Scaffold(
      drawer: NavigationDrawerWidget(
        name: name,
      ),
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.6,
                child: GoogleMap(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    const Text(
                      'Activity Call',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(
                      height: 5,
                      thickness: 3,
                    ),
                    const Text(
                      'Waiting List:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Column(
                        // This will read the Waiting list from Firebase (SOSEmergencies)

                        children: <Widget>[
                          SizedBox(
                              height: 200.0,

                              child: StreamBuilder<QuerySnapshot>(
                                  stream: Waiting,
                                  builder: (
                                    BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot,
                                  ) {
                                    if (snapshot.hasError) {
                                      return Text(
                                          'Something went wrong  ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading');
                                    }

                                    final data = snapshot.requireData;

                                    return ListView.builder(
                                        itemCount: data.size,
                                        itemBuilder: (context, index) {
                                          getTimeWaited(data.docs[index].id);
                                          String phone = " ";
                                          var id = data.docs[index].id;
                                          phone = data.docs[index]['Phone']
                                              .toString();
                                          if (data.docs[index]['Waiting']) {
                                            return Material(
                                              child: Container(
                                                child: Row(children: <Widget>[
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.red),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => CallControlPanel(
                                                                  CallerId: id,
                                                                  Snapshot: data
                                                                          .docs[
                                                                      index],
                                                                  signaling:
                                                                      signaling,
                                                                  localRenderer:
                                                                      _localRenderer,
                                                                  remoteRenderer:
                                                                      _remoteRenderer,name: name,)));
                                                    },
                                                    child: Text(
                                                        ' ${phone + "  Time waited: " + timeWaitedString!}'),
                                                  ),
                                                ]),
                                              ),
                                            );
                                          } else {
                                            return const Material();
                                          }
                                          //return Text('Date: ${data.docs[index]['date']}\n Start time: ${data.docs[index]['Start time']}\n End Time: ${data.docs[index]['End time']}\n Status: ${data.docs[index]['Status']}');
                                        });
                                  }))
                        ]),
                    const Divider(
                      height: 2,
                      thickness: 2,
                    ),
                    const Text(
                      'Online List:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Column(
                        // This will read the Online list from Firebase (SOSEmergencies)

                        children: <Widget>[
                          SizedBox(
                              height: 200.0,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: Waiting,
                                  builder: (
                                    BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot,
                                  ) {
                                    if (snapshot.hasError) {
                                      return Text(
                                          'Something went wrong  ${snapshot.error}');
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text('Loading');
                                    }

                                    final data = snapshot.requireData;
                                    return ListView.builder(
                                        itemCount: data.size,
                                        itemBuilder: (context, index) {
                                          var id = data.docs[index].id;
                                          if (data.docs[index]['Online']) {
                                            return Material(
                                              child: Container(
                                                height: 30,
                                                child: Row(children: <Widget>[
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.blue),
                                                    ),
                                                    onPressed: () {},
                                                    child: Text(
                                                        '${data.docs[index]['Phone']}'),
                                                  ),
                                                ]),
                                              ),
                                            );
                                          } else {
                                            return const Material();
                                          }
                                          //return Text('Date: ${data.docs[index]['date']}\n Start time: ${data.docs[index]['Start time']}\n End Time: ${data.docs[index]['End time']}\n Status: ${data.docs[index]['Status']}');
                                        });
                                  }))
                        ]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ));
}
