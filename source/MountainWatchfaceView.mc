import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    var backgroundBitmap;
    var timeFont;

    function initialize() {
        WatchFace.initialize();

        backgroundBitmap = WatchUi.loadResource(Rez.Drawables.MountainBackground);
        timeFont = WatchUi.loadResource(Rez.Fonts.TimeDigits);
    }

    function onUpdate(dc) {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawBackground(dc, screenWidth, screenHeight);
        drawTime(dc, screenWidth, screenHeight);
        drawDate(dc, screenWidth, screenHeight);
    }

    function drawBackground(dc, screenWidth, screenHeight) {
        if (backgroundBitmap == null) {
            return;
        }

        var backgroundX = (screenWidth - backgroundBitmap.getWidth()) / 2;
        var backgroundY = (screenHeight - backgroundBitmap.getHeight()) / 2;
        dc.drawBitmap(backgroundX, backgroundY, backgroundBitmap);
    }

    function drawTime(dc, screenWidth, screenHeight) {
        var clockTime = System.getClockTime();
        var displayHour = clockTime.hour;
        var displayMinute = clockTime.min;
        var deviceSettings = System.getDeviceSettings();

        if (!(deviceSettings.is24Hour)) {
            displayHour = displayHour % 12;

            if (displayHour == 0) {
                displayHour = 12;
            }
        }

        var hourText = Lang.format("$1$", [displayHour]);
        if (displayHour < 10) {
            hourText = "0" + hourText;
        }

        var minuteText = Lang.format("$1$", [displayMinute]);
        if (displayMinute < 10) {
            minuteText = "0" + minuteText;
        }

        var screenCenterX = screenWidth / 2;
        var screenCenterY = screenHeight / 2;
        var timeBaselineY = screenCenterY + 33;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenCenterX - 57, timeBaselineY, timeFont, hourText, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(screenCenterX + 1, timeBaselineY, timeFont, ":", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(screenCenterX + 57, timeBaselineY, timeFont, minuteText, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawDate(dc, screenWidth, screenHeight) {
        var currentDate = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthText = Lang.format("$1$", [currentDate.month]);
        var dayText = Lang.format("$1$", [currentDate.day]);
        var dateText = monthText + "/" + dayText;
        var screenCenterX = screenWidth / 2;
        var screenCenterY = screenHeight / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(screenCenterX, screenCenterY + 67, Graphics.FONT_TINY, dateText, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
