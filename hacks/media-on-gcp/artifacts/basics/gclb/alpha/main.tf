# Google-managed SSL certificate
resource "google_compute_managed_ssl_certificate" "viper_media_ghacks_dev" {
  name = "viper-media-ghacks-dev"
  managed {
    domains = [
      "viper.media.ghacks.dev",
      "norsk.viper.media.ghacks.dev",
      "darwin.viper.media.ghacks.dev",
      "gemini.viper.media.ghacks.dev",
      "titan.viper.media.ghacks.dev",
      "nea.viper.media.ghacks.dev",
      "cdn.viper.media.ghacks.dev",
      "player.viper.media.ghacks.dev",
    ]
  }
}
