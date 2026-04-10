import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onUpdate(dc) {
        var clockTime = System.getClockTime();
        var displayHour = clockTime.hour;
        var displayMinute = clockTime.min;
        var deviceSettings = System.getDeviceSettings();
        var hourLabel = View.findDrawableById("HourLabel") as WatchUi.Text;
        var minuteLabel = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        var heartRateLabel = View.findDrawableById("HeartRateLabel") as WatchUi.Text;
        var notificationCountLabel = View.findDrawableById("NotificationCountLabel") as WatchUi.Text;

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

        var currentDate = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthText = normalizeMonthCase(Lang.format("$1$", [currentDate.month]));
        var dayText = Lang.format("$1$", [currentDate.day]);
        var dateText = monthText + " " + dayText;
        var heartRateText = "00";
        var notificationCountText = "00";

        hourLabel.setText(hourText);
        minuteLabel.setText(minuteText);
        dateLabel.setText(dateText);
        heartRateLabel.setText(heartRateText);
        notificationCountLabel.setText(notificationCountText);

        View.onUpdate(dc);
    }

    function normalizeMonthCase(monthText) {
        if ((monthText == null) || (monthText.length() == 0)) {
            return "";
        }

        if (monthText.length() == 1) {
            return monthText;
        }

        return monthText.substring(0, 1).toUpper() + monthText.substring(1, monthText.length()).toLower();
    }
}
