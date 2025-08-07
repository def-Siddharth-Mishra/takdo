import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget that provides responsive layout capabilities
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (AppTheme.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (AppTheme.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// A widget that provides responsive padding
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    if (AppTheme.isDesktop(context)) {
      padding = desktop ?? tablet ?? mobile ?? AppTheme.getResponsivePadding(context);
    } else if (AppTheme.isTablet(context)) {
      padding = tablet ?? mobile ?? AppTheme.getResponsivePadding(context);
    } else {
      padding = mobile ?? AppTheme.getResponsivePadding(context);
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// A widget that constrains content width for better readability on larger screens
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double? maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerMaxWidth = maxWidth ?? AppTheme.getCardMaxWidth(context);

    if (screenWidth <= containerMaxWidth) {
      return child;
    }

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: containerMaxWidth,
        child: child,
      ),
    );
  }
}

/// A widget that provides responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    int columns;
    
    if (AppTheme.isDesktop(context)) {
      columns = desktopColumns;
    } else if (AppTheme.isTablet(context)) {
      columns = tabletColumns;
    } else {
      columns = mobileColumns;
    }

    if (columns == 1) {
      return Column(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: runSpacing),
                  child: child,
                ))
            .toList(),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        final width = (MediaQuery.of(context).size.width - 
                      (spacing * (columns - 1)) - 
                      (AppTheme.getResponsivePadding(context).horizontal)) / columns;
        
        return SizedBox(
          width: width,
          child: child,
        );
      }).toList(),
    );
  }
}

/// A widget that provides responsive text scaling
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileScale = 1.0,
    this.tabletScale = 1.1,
    this.desktopScale = 1.2,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final double mobileScale;
  final double tabletScale;
  final double desktopScale;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    double scale;
    
    if (AppTheme.isDesktop(context)) {
      scale = desktopScale;
    } else if (AppTheme.isTablet(context)) {
      scale = tabletScale;
    } else {
      scale = mobileScale;
    }

    final scaledStyle = style?.copyWith(
      fontSize: (style?.fontSize ?? 14) * scale,
    );

    return Text(
      text,
      style: scaledStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A widget that provides responsive spacing
class ResponsiveSpacing extends StatelessWidget {
  const ResponsiveSpacing({
    super.key,
    this.mobile = 16,
    this.tablet = 24,
    this.desktop = 32,
    this.axis = Axis.vertical,
  });

  final double mobile;
  final double tablet;
  final double desktop;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    double spacing;
    
    if (AppTheme.isDesktop(context)) {
      spacing = desktop;
    } else if (AppTheme.isTablet(context)) {
      spacing = tablet;
    } else {
      spacing = mobile;
    }

    return SizedBox(
      width: axis == Axis.horizontal ? spacing : null,
      height: axis == Axis.vertical ? spacing : null,
    );
  }
}