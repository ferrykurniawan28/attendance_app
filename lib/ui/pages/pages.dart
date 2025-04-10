import 'dart:async';
import 'dart:io';

import 'package:attendance/models/models.dart';
import 'package:attendance/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'auth/login.dart';
part 'splash.dart';
part 'home.dart';
part 'profile.dart';
part 'attendance.dart';
part 'home_main.dart';
part 'attendance_history.dart';
part 'attendance_detail.dart';
