using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {

    var mBackground;
    var mTimeFont;

    function initialize() {
        WatchFace.initialize();

        mBackground = WatchUi.loadResource(Rez.Drawables.MountainBackground);
        mTimeFont = WatchUi.loadResource(Rez.Fonts.TimeDigits);
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawBackground(dc, width, height);
        drawTime(dc, width, height);
        drawDate(dc, width, height);
    }

    function drawBackground(dc, width, height) {
        if (mBackground == null) {
            return;
        }

        var bgX = (width - mBackground.getWidth()) / 2;
        var bgY = (height - mBackground.getHeight()) / 2;
        dc.drawBitmap(bgX, bgY, mBackground);
    }

    function drawTime(dc, width, height) {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var deviceSettings = System.getDeviceSettings();

        if (!(deviceSettings.is24Hour)) {
            hours = hours % 12;

            if (hours == 0) {
                hours = 12;
            }
        }

        var hourString = Lang.format("$1$", [hours]);
        if (hours < 10) {
            hourString = "0" + hourString;
        }

        var minuteString = Lang.format("$1$", [minutes]);
        if (minutes < 10) {
            minuteString = "0" + minuteString;
        }

        var timeText = hourString + ":" + minuteString;
        var baselineY = height - 56;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, baselineY, mTimeFont, timeText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawDate(dc, width, height) {
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthString = Lang.format("$1$", [today.month]);
        var dayString = Lang.format("$1$", [today.day]);
        var dateText = monthString + "/" + dayString;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height - 20, Graphics.FONT_TINY, dateText, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
