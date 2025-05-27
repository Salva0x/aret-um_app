import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  // Función para abrir un enlace
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url); // Convertir el enlace a Uri

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 8),
      child: Container(
        color: const Color(0xFFEAE7D6),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fila con los íconos de redes sociales
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón para abrir WhatsApp
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                  ),
                  onPressed:
                      () => _launchURL('https://wa.me/tuNumeroDeWhatsApp'),
                ),
                // Botón para abrir Facebook
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.facebook,
                    color: Colors.blue,
                  ),
                  onPressed:
                      () => _launchURL(
                        'https://www.facebook.com/tuPerfilDeFacebook',
                      ),
                ),
                // Botón para abrir Instagram
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.instagram,
                    color: Colors.pink,
                  ), // Ícono de Instagram
                  onPressed:
                      () => _launchURL(
                        'https://www.instagram.com/tuPerfilDeInstagram',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Texto con el símbolo de copyright y el mensaje de la app
            const Text(
              "Aretéum, © | Verdad, Bondad, Justicia y Belleza",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
