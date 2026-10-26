import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveRepo {
  ResponsiveRepo(this.context);

  final BuildContext context;

  // MediaQuery

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  EdgeInsets get padding => mediaQuery.padding;

  Orientation get orientation => mediaQuery.orientation;

  // Breakpoints

  /// Mobile breakpoint.
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint.
  static const double tabletBreakpoint = 1024;

  /// Desktop breakpoint.
  static const double desktopBreakpoint = 1440;

  bool get isMobile => screenWidth < mobileBreakpoint;

  bool get isTablet =>
      screenWidth >= mobileBreakpoint &&
          screenWidth < tabletBreakpoint;

  bool get isDesktop => screenWidth >= tabletBreakpoint;

  bool get isLargeDesktop => screenWidth >= desktopBreakpoint;

  bool get isLandscape => orientation == Orientation.landscape;

  bool get isPortrait => orientation == Orientation.portrait;

  // Device Type

  /// Returns true for mobile-sized screens.
  bool get isMobileWidth => screenWidth < mobileBreakpoint;

  /// Returns true for tablet and larger screens.
  bool get isTabletOrLarger => screenWidth >= mobileBreakpoint;

  /// Returns true for desktop-sized screens.
  bool get isDesktopWidth => screenWidth >= tabletBreakpoint;

  // Width

  /// Returns a percentage of the available screen width.
  ///
  /// Example:
  /// responsive.w(50) => 50% of screen width.
  double w(double percentage) {
    return screenWidth * (percentage / 100);
  }

  /// Returns a width value while preventing it from exceeding [max].
  double wMax(
      double percentage, {
        double? max,
        double? min,
      }) {
    final value = w(percentage);

    if (min != null && value < min) {
      return min;
    }

    if (max != null && value > max) {
      return max;
    }

    return value;
  }

  // Height

  /// Returns a percentage of the available screen height.
  ///
  /// Example:
  /// responsive.h(10) => 10% of screen height.
  double h(double percentage) {
    return screenHeight * (percentage / 100);
  }

  /// Returns a height value while preventing it from exceeding [max].
  double hMax(
      double percentage, {
        double? max,
        double? min,
      }) {
    final value = h(percentage);

    if (min != null && value < min) {
      return min;
    }

    if (max != null && value > max) {
      return max;
    }

    return value;
  }

  // Font Size

  /// Responsive font size based on screen width.
  ///
  /// [size] represents the base font size.
  ///
  /// The scaling is intentionally limited so text doesn't become
  /// unnecessarily large or small on extreme screen sizes.
  double font(
      double size, {
        double min = 10,
        double max = 60,
      }) {
    const baseWidth = 375.0;

    final scale = screenWidth / baseWidth;

    final responsiveSize = size * scale;

    return responsiveSize.clamp(min, max).toDouble();
  }

  /// Font size based on the smaller screen dimension.
  ///
  /// Useful for UI elements that need to remain visually balanced
  /// in both portrait and landscape.
  double fontAdaptive(
      double size, {
        double min = 10,
        double max = 60,
      }) {
    const baseDimension = 375.0;

    final smallestDimension = math.min(screenWidth, screenHeight);

    final scale = smallestDimension / baseDimension;

    final responsiveSize = size * scale;

    return responsiveSize.clamp(min, max).toDouble();
  }

  // Spacing

  /// Responsive spacing based on screen width.
  ///
  /// This should be used for margins, padding and gaps where appropriate.
  double spacing(
      double value, {
        double min = 2,
        double max = 100,
      }) {
    final responsiveValue = w(value / 3.75);

    return responsiveValue.clamp(min, max).toDouble();
  }

  // ---------------------------------------------------------------------------
  // Radius
  // ---------------------------------------------------------------------------

  /// Responsive border radius.
  double radius(
      double value, {
        double min = 2,
        double max = 50,
      }) {
    final responsiveValue = value * (screenWidth / 375);

    return responsiveValue.clamp(min, max).toDouble();
  }

  // ---------------------------------------------------------------------------
  // Icon Size
  // ---------------------------------------------------------------------------

  /// Responsive icon size.
  double icon(
      double size, {
        double min = 12,
        double max = 60,
      }) {
    final responsiveSize = size * (screenWidth / 375);

    return responsiveSize.clamp(min, max).toDouble();
  }

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------

  /// Responsive app bar height.
  double get appBarHeight {
    if (isMobile) {
      return hMax(
        8,
        min: kToolbarHeight,
        max: 72,
      );
    }

    if (isTablet) {
      return 72;
    }

    return 80;
  }

  // ---------------------------------------------------------------------------
  // Horizontal / Vertical Padding
  // ---------------------------------------------------------------------------

  double get horizontalPadding {
    if (isMobile) {
      return wMax(5, min: 16, max: 24);
    }

    if (isTablet) {
      return wMax(4, min: 24, max: 40);
    }

    return wMax(3, min: 32, max: 60);
  }

  double get verticalPadding {
    if (isMobile) {
      return hMax(2, min: 12, max: 24);
    }

    if (isTablet) {
      return hMax(2, min: 20, max: 32);
    }

    return hMax(2, min: 24, max: 40);
  }

  // ---------------------------------------------------------------------------
  // Safe Area
  // ---------------------------------------------------------------------------

  double get topSafeArea => viewPadding.top;

  double get bottomSafeArea => viewPadding.bottom;

  double get leftSafeArea => viewPadding.left;

  double get rightSafeArea => viewPadding.right;

  // ---------------------------------------------------------------------------
  // Content Width
  // ---------------------------------------------------------------------------

  /// Maximum content width for larger screens.
  ///
  /// Prevents content from stretching excessively on tablets/desktops.
  double get contentMaxWidth {
    if (isMobile) {
      return screenWidth;
    }

    if (isTablet) {
      return 900;
    }

    return 1200;
  }

  /// Returns a responsive content width.
  double get contentWidth {
    return math.min(screenWidth, contentMaxWidth);
  }

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------

  /// Calculates how many columns should be displayed.
  int gridColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    if (isLargeDesktop) {
      return largeDesktop;
    }

    if (isDesktop) {
      return desktop;
    }

    if (isTablet) {
      return tablet;
    }

    return mobile;
  }

  /// Calculates a responsive grid item width.
  double gridItemWidth({
    required int columns,
    double spacing = 16,
  }) {
    final totalSpacing = spacing * (columns - 1);

    return (contentWidth - totalSpacing) / columns;
  }

  // ---------------------------------------------------------------------------
  // Device Helpers
  // ---------------------------------------------------------------------------

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop && largeDesktop != null) {
      return largeDesktop;
    }

    if (isDesktop && desktop != null) {
      return desktop;
    }

    if (isTablet && tablet != null) {
      return tablet;
    }

    return mobile;
  }

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  bool get isKeyboardVisible => viewInsets.bottom > 0;

  double get keyboardHeight => viewInsets.bottom;

  // ---------------------------------------------------------------------------
  // Orientation Helpers
  // ---------------------------------------------------------------------------

  T orientationValue<T>({
    required T portrait,
    required T landscape,
  }) {
    return isPortrait ? portrait : landscape;
  }
}