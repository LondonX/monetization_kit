package com.LondonX.monetization_kit.entity

import android.graphics.Color

data class ColorScheme(
    val brightness: Brightness,
    val primary: FlutterColor,
    val onPrimary: FlutterColor,
    val secondary: FlutterColor,
    val onSecondary: FlutterColor,
    val error: FlutterColor,
    val onError: FlutterColor,
    val background: FlutterColor,
    val onBackground: FlutterColor,
    val surface: FlutterColor,
    val onSurface: FlutterColor,
) {
    companion object {
        fun fromRaw(raw: Map<*, *>): ColorScheme {
            val brightness = if (raw["brightness"] == "dark") Brightness.dark else Brightness.light
            val primary = raw["primary"] as Long
            val onPrimary = raw["onPrimary"] as Long
            val secondary = raw["secondary"] as Long
            val onSecondary = raw["onSecondary"] as Long
            val error = raw["error"] as Long
            val onError = raw["onError"] as Long
            val background = raw["background"] as Long
            val onBackground = raw["onBackground"] as Long
            val surface = raw["surface"] as Long
            val onSurface = raw["onSurface"] as Long
            return ColorScheme(
                brightness,
                primary.let { FlutterColor.from(it) },
                onPrimary.let { FlutterColor.from(it) },
                secondary.let { FlutterColor.from(it) },
                onSecondary.let { FlutterColor.from(it) },
                error.let { FlutterColor.from(it) },
                onError.let { FlutterColor.from(it) },
                background.let { FlutterColor.from(it) },
                onBackground.let { FlutterColor.from(it) },
                surface.let { FlutterColor.from(it) },
                onSurface.let { FlutterColor.from(it) },
            )
        }
    }
}

enum class Brightness {
    light, dark,
}

data class FlutterColor(val a: Int, val r: Int, val g: Int, val b: Int) {
    companion object {
        fun from(v: Int): FlutterColor {
            return from(v.toUInt().toLong())
        }

        fun from(v: Long): FlutterColor {
            val a = v shr 24 and 0xFF
            val r = v shr 16 and 0xFF
            val g = v shr 8 and 0xFF
            val b = v shr 0 and 0xFF
            return FlutterColor(a.toInt(), r.toInt(), g.toInt(), b.toInt())
        }
    }

    val v: Int get() = Color.argb(a, r, g, b)
}