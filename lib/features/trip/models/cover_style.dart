enum CoverStyle {
  impressionist,
  watercolor,
  surrealism,
  vintage,
  glassaic,
  vectorial,
  paperCut,
  childish,
  mattePainting,
  embroidery,
}

extension CoverStyleExtension on CoverStyle {
  String get displayName {
    switch (this) {
      case CoverStyle.impressionist:
        return 'Impressionista';
      case CoverStyle.watercolor:
        return 'Aquarela';
      case CoverStyle.surrealism:
        return 'Surrealismo';
      case CoverStyle.vintage:
        return 'Vintage';
      case CoverStyle.glassaic:
        return 'Mosaico de Vidro';
      case CoverStyle.vectorial:
        return 'Vetorial';
      case CoverStyle.paperCut:
        return 'Papel Recortado';
      case CoverStyle.childish:
        return 'Infantil';
      case CoverStyle.mattePainting:
        return 'Matte Painting';
      case CoverStyle.embroidery:
        return 'Bordado';
    }
  }

  String get description {
    switch (this) {
      case CoverStyle.impressionist:
        return 'Estilo artístico com pinceladas visíveis e cores vibrantes';
      case CoverStyle.watercolor:
        return 'Efeito de aquarela com cores suaves e fluidas';
      case CoverStyle.surrealism:
        return 'Arte surrealista com elementos fantásticos';
      case CoverStyle.vintage:
        return 'Estilo retrô com cores desbotadas';
      case CoverStyle.glassaic:
        return 'Efeito de mosaico com peças de vidro colorido';
      case CoverStyle.vectorial:
        return 'Arte vetorial com formas geométricas limpas';
      case CoverStyle.paperCut:
        return 'Estilo de papel recortado em camadas';
      case CoverStyle.childish:
        return 'Arte infantil com traços simples e cores alegres';
      case CoverStyle.mattePainting:
        return 'Pintura digital cinematográfica';
      case CoverStyle.embroidery:
        return 'Efeito de bordado com texturas de linha';
    }
  }
}