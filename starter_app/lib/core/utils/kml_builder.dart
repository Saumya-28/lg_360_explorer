import 'dart:math' as math;
import '../constants/lg_constants.dart';

/// Utility class for building KML content
class KMLBuilder {
  final StringBuffer _buffer = StringBuffer();
  bool _hasHeader = false;

  /// Adds KML header
  KMLBuilder addHeader() {
    if (!_hasHeader) {
      _buffer.write(LGConstants.kmlHeader);
      _hasHeader = true;
    }
    return this;
  }

  /// Adds a LookAt element
  KMLBuilder addLookAt({
    required double longitude,
    required double latitude,
    required double range,
    double tilt = 0,
    double heading = 0,
  }) {
    _buffer.write(LGConstants.lookAt(
      longitude: longitude,
      latitude: latitude,
      range: range,
      tilt: tilt,
      heading: heading,
    ));
    return this;
  }

  /// Adds a Placemark
  KMLBuilder addPlacemark({
    required String name,
    required double longitude,
    required double latitude,
    String? description,
  }) {
    _buffer.write(LGConstants.placemark(
      name: name,
      longitude: longitude,
      latitude: latitude,
      description: description,
    ));
    return this;
  }

  /// Adds custom KML content
  KMLBuilder addCustom(String kml) {
    _buffer.write(kml);
    return this;
  }

  /// Builds the final KML string with footer
  String build() {
    if (!_hasHeader) {
      addHeader();
    }
    _buffer.write(LGConstants.kmlFooter);
    return _buffer.toString();
  }

  /// Creates a simple orbit KML
  static String createOrbit({
    required double longitude,
    required double latitude,
    double range = 1000,
    double tilt = 60,
  }) {
    return KMLBuilder()
        .addHeader()
        .addLookAt(
          longitude: longitude,
          latitude: latitude,
          range: range,
          tilt: tilt,
        )
        .build();
  }

  /// Creates a balloon KML
  static String createBalloon({
    required String title,
    required String content,
    required double longitude,
    required double latitude,
  }) {
    final balloonKml = '''
<Placemark>
  <name>$title</name>
  <description><![CDATA[$content]]></description>
  <gx:balloonVisibility>1</gx:balloonVisibility>
  <Point>
    <coordinates>$longitude,$latitude,0</coordinates>
  </Point>
</Placemark>''';

    return KMLBuilder()
        .addHeader()
        .addCustom(balloonKml)
        .build();
  }

  /// Creates a ScreenOverlay KML with custom positioning
  static String createScreenOverlay({
    required String imageUrl,
    required String title,
    required String content,
    double overlayX = 0,
    double overlayY = 1,
    double screenX = 0.02,
    double screenY = 0.95,
    double sizeX = 0,
    double sizeY = 0,
  }) {
    final overlayKml = '''
<ScreenOverlay>
  <name>$title</name>
  <Icon>
    <href>$imageUrl</href>
  </Icon>
  <overlayXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
  <screenXY x="$screenX" y="$screenY" xunits="fraction" yunits="fraction"/>
  <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
  <size x="$sizeX" y="$sizeY" xunits="pixels" yunits="pixels"/>
</ScreenOverlay>
''';
    
    return KMLBuilder()
        .addHeader()
        .addCustom(overlayKml)
        .build();
  }

  /// Creates a KML for the ISS icon
  static String createISSIcon({
    required double latitude,
    required double longitude,
    double altitude = 400000, 
  }) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>ISS Location</name>
    <Style id="iss-icon">
      <IconStyle>
        <scale>2.0</scale>
        <Icon>
          <href>https://upload.wikimedia.org/wikipedia/commons/d/d0/International_Space_Station.svg</href>
        </Icon>
      </IconStyle>
    </Style>
    <Placemark>
      <name>ISS</name>
      <description>Current ISS Location</description>
      <styleUrl>#iss-icon</styleUrl>
      <Point>
        <extrude>1</extrude>
        <altitudeMode>absolute</altitudeMode>
        <coordinates>\$longitude,\$latitude,\$altitude</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>''';
  }

  /// Creates a KML for the ISS orbit path
  static String createISSOrbitPath(List<dynamic> positions) {
    if (positions.isEmpty) return '';
    
    final coordinates = positions.map((p) => '${p.longitude},${p.latitude},400000').join(' ');

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>ISS Path</name>
    <Style id="iss-path-style">
      <LineStyle>
        <color>ff00ffff</color> <!-- Yellow line -->
        <width>4</width>
      </LineStyle>
    </Style>
    <Placemark>
      <name>ISS Orbit</name>
      <styleUrl>#iss-path-style</styleUrl>
      <LineString>
        <extrude>1</extrude>
        <tessellate>1</tessellate>
        <altitudeMode>absolute</altitudeMode>
        <coordinates>
          $coordinates
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''';
  }

  /// Creates a combined KML for ISS tracker (Icon + Path)
  static String createISSTrackerKML(List<dynamic> positions) {
    if (positions.isEmpty) return '';
    final last = positions.last;
    
    // Use clampToGround for path to ensure visibility on map
    final coordinates = positions.map((p) => '${p.longitude},${p.latitude},0').join(' ');

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>ISS Tracker</name>
    <Style id="iss-icon">
      <IconStyle>
        <scale>2.0</scale>
        <Icon>
          <href>https://upload.wikimedia.org/wikipedia/commons/d/d0/International_Space_Station.svg</href>
        </Icon>
      </IconStyle>
    </Style>
    <Style id="iss-path-style">
      <LineStyle>
        <color>ff00ffff</color>
        <width>5</width>
      </LineStyle>
    </Style>
    
    <Placemark>
      <name>ISS</name>
      <styleUrl>#iss-icon</styleUrl>
      <Point>
        <extrude>1</extrude>
        <altitudeMode>absolute</altitudeMode>
        <coordinates>${last.longitude},${last.latitude},400000</coordinates>
      </Point>
    </Placemark>
    
    <Placemark>
      <name>ISS Orbit</name>
      <styleUrl>#iss-path-style</styleUrl>
      <LineString>
        <extrude>1</extrude>
        <tessellate>1</tessellate>
        <altitudeMode>clampToGround</altitudeMode>
        <coordinates>
          $coordinates
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''';
  }

  /// Creates a City Tour KML with true orbital motion
  static String createCityTour({
    required String tourName,
    required double latitude,
    required double longitude,
    double range = 5000,
    double tilt = 60,
    double orbitDuration = 5.0,
  }) {
    StringBuffer playlist = StringBuffer();
    
    // 1. Initial FlyTo to starting position
    playlist.write('''
      <gx:FlyTo>
        <gx:duration>1.0</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$longitude</longitude>
          <latitude>$latitude</latitude>
          <range>$range</range>
          <tilt>$tilt</tilt>
          <heading>0</heading>
          <altitudeMode>relativeToGround</altitudeMode>
        </LookAt>
      </gx:FlyTo>
    ''');

    // 2. True orbital motion - move camera in circle around target
    // 18 steps for smooth motion and rig compatibility
    const int steps = 18;
    double stepDuration = orbitDuration / steps;
    
    for (int i = 1; i <= steps; i++) {
      double heading = (i * 20.0) % 360;
      
      playlist.write('''
      <gx:FlyTo>
        <gx:duration>$stepDuration</gx:duration>
        <gx:flyToMode>smooth</gx:flyToMode>
        <LookAt>
          <longitude>$longitude</longitude>
          <latitude>$latitude</latitude>
          <range>$range</range>
          <tilt>$tilt</tilt>
          <heading>$heading</heading>
          <altitudeMode>relativeToGround</altitudeMode>
        </LookAt>
      </gx:FlyTo>
      ''');
    }

    // 3. Post-orbit wait
    playlist.write('''
      <gx:Wait>
        <gx:duration>2.0</gx:duration>
      </gx:Wait>
    ''');

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>$tourName</name>
    <gx:Tour>
      <name>$tourName</name>
      <gx:Playlist>
        $playlist
      </gx:Playlist>
    </gx:Tour>
  </Document>
</kml>''';
  }

  /// Creates a KML containing tours for all cities
  static String createAllToursKML(List<dynamic> cities) {
    StringBuffer allTours = StringBuffer();

    for (var city in cities) {
      final sanitizedName = city.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
      final tourName = 'Tour_$sanitizedName';
      
      StringBuffer playlist = StringBuffer();
      
      // 1. Initial FlyTo (Fast alignment)
      playlist.write('''
        <gx:FlyTo>
          <gx:duration>1.0</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>${city.longitude}</longitude>
            <latitude>${city.latitude}</latitude>
            <range>5000</range>
            <tilt>60</tilt>
            <heading>0</heading>
            <altitudeMode>relativeToGround</altitudeMode>
          </LookAt>
        </gx:FlyTo>
      ''');

      // 2. Orbit (360 degrees)
      // 8 steps of 45 degrees
      for (int i = 1; i <= 8; i++) {
        double heading = (i * 45.0);
        playlist.write('''
        <gx:FlyTo>
          <gx:duration>1.5</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>${city.longitude}</longitude>
            <latitude>${city.latitude}</latitude>
            <range>5000</range>
            <tilt>60</tilt>
            <heading>$heading</heading>
            <altitudeMode>relativeToGround</altitudeMode>
          </LookAt>
        </gx:FlyTo>
        ''');
      }

      // 3. Post-Orbit Wait (5 seconds)
      playlist.write('''
        <gx:Wait>
          <gx:duration>5.0</gx:duration>
        </gx:Wait>
      ''');

      allTours.write('''
      <gx:Tour>
        <name>$tourName</name>
        <gx:Playlist>
          $playlist
        </gx:Playlist>
      </gx:Tour>
      ''');
    }

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
  <Document>
    <name>All City Tours</name>
    $allTours
  </Document>
</kml>''';
  }
}
