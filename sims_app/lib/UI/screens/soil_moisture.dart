import 'package:SIMS/UI/utils/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../auth/login_screen.dart';
import '../utils/utils.dart';

class SoilMoisture extends StatefulWidget {
  const SoilMoisture({super.key});

  @override
  State<SoilMoisture> createState() => _SoilMoistureState();
}

class _SoilMoistureState extends State<SoilMoisture> {

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    bool loading = false;
    final auth = FirebaseAuth.instance;
    final ref = FirebaseDatabase.instance.ref('realtimeSoilData');
    String UserId = '';

    double soilMoisture = 0.0;
    double tankVolume = 0.0;
    double tankCapacity = 0.0;
    double value = 0;
    String val = "";

    void initState() {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        UserId = user!.uid;
        ref.child(UserId).child('Tank Capacity').onValue.listen((event) {
          tankCapacity = double.parse(event.snapshot.value.toString());
          debugPrint("Tank Capacity: $tankCapacity");
        });
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("S.I.M.S Home"),
          leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                    onPressed: () {
                      auth.signOut().then((value) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => LoginScreen()));
                      }).onError((error, stackTrace) {
                        Utils().toastMessage(error.toString());
                      });
                    },
                    icon: const Icon(Icons.logout_outlined));
              }
            ),
            const SizedBox(width: 10),
          ],
        ),
        drawer: const AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Realtime data from the Field",
                style: TextStyle(color: Colors.deepPurple, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData) {
                    debugPrint("$soilMoisture");
                    return CircularProgressIndicator();
                  } else {
                    ref
                        .child(UserId)
                        .child('Soil Moisture')
                        .onValue
                        .listen((event) {
                      soilMoisture =
                          double.parse(event.snapshot.value.toString());
                      soilMoisture =
                          double.parse(soilMoisture.toStringAsFixed(3));
                      debugPrint("Moisture: $soilMoisture");
                    });

                    return SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          interval: 10,
                          ranges: [
                            GaugeRange(
                              startValue: 0,
                              endValue: 20,
                              color: Colors.orange,
                            ),
                            GaugeRange(
                              startValue: 20,
                              endValue: 60,
                              color: Colors.green,
                            ),
                            GaugeRange(
                              startValue: 60,
                              endValue: 75,
                              color: Colors.yellow,
                            ),
                            GaugeRange(
                                startValue: 75,
                                endValue: 100,
                                color: Colors.blue)
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              value: soilMoisture,
                              enableAnimation: true,
                            )
                          ],
                          annotations: [
                            GaugeAnnotation(
                              widget: Text("Moisture level: $soilMoisture%",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15)),
                              positionFactor: 1,
                              angle: 90,
                            ),
                          ],
                        )
                      ],
                    );
                  }
                },
              )),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      );
    }
  }
