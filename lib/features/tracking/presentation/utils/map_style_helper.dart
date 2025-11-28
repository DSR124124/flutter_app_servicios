/// Helper para generar estilos personalizados de Google Maps
/// Basado en los colores de la empresa NETTALCO
/// Estilo con colores corporativos visibles y profesionales
class MapStyleHelper {
  /// Estilo personalizado del mapa con colores de la empresa
  /// Aplica colores corporativos NETTALCO (navy #1C224D, blue #4A7AFF, mint #A2F0A1)
  /// Colores más visibles y contrastados para mejor legibilidad
  static String getCustomMapStyle() {
    return '''
[
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#6B8FFF"
      },
      {
        "lightness": 10
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4A7AFF"
      },
      {
        "lightness": -10
      }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#F7FAFC"
      },
      {
        "lightness": 5
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#EDF2F7"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#D1D5DB"
      },
      {
        "lightness": 0
      },
      {
        "weight": 1
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#FFFFFF"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#E6E6E6"
      },
      {
        "lightness": 0
      },
      {
        "weight": 0.5
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#FFFFFF"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#E6E6E6"
      },
      {
        "lightness": 0
      },
      {
        "weight": 0.5
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#F7FAFC"
      },
      {
        "lightness": 0
      },
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#B8F5B7"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#A2F0A1"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "visibility": "on"
      },
      {
        "color": "#FFFFFF"
      },
      {
        "lightness": 0
      },
      {
        "weight": 2
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "saturation": 0
      },
      {
        "color": "#1C224D"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#EDF2F7"
      },
      {
        "lightness": 0
      },
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#FFFFFF"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#E6E6E6"
      },
      {
        "lightness": 0
      },
      {
        "weight": 1
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#1C224D"
      },
      {
        "lightness": 0
      }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
''';
  }
}
