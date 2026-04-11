import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Activity;

class MountainWatchfaceView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onUpdate(dc) {
        var deviceSettings = System.getDeviceSettings();

        var clockTime = System.getClockTime();
        var displayHour = clockTime.hour;
        var displayMinute = clockTime.min;
        var displaySeconds = clockTime.sec;

        var hourLabel = View.findDrawableById("HourLabel") as WatchUi.Text;
        var minuteLabel = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        var secondsLabel = View.findDrawableById("SecondsLabel") as WatchUi.Text;
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        var weatherTemperatureLabel = View.findDrawableById("WeatherTemperatureLabel") as WatchUi.Text;
        var heartRateLabel = View.findDrawableById("HeartRateLabel") as WatchUi.Text;
        var notificationCountLabel = View.findDrawableById("NotificationCountLabel") as WatchUi.Text;

        if (!(deviceSettings.is24Hour)) {
            displayHour = displayHour % 12;

            if (displayHour == 0) {
                displayHour = 12;
            }
        }

        var hourText = displayHour.toString();
        if (displayHour < 10) {
            hourText = "0" + hourText;
        }

        var minuteText = displayMinute.toString();
        if (displayMinute < 10) {
            minuteText = "0" + minuteText;
        }

        var secondsText = displaySeconds.toString();
        if (displaySeconds < 10) {
            secondsText = "0" + secondsText;
        }

        var currentDate = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthText = normalizeMonthCase(currentDate.month.toString());
        var dayText = currentDate.day.toString();
        var dateText = monthText + " " + dayText;

        var activityInfo = Activity.getActivityInfo();
        var heartRateText = activityInfo.currentHeartRate != null ? activityInfo.currentHeartRate.toString() : "--";

        var notificationCountText = deviceSettings.notificationCount.toString();

        var currentWeatherConditions = Weather.getCurrentConditions();
        var localizedTemperatureValue = deviceSettings.temperatureUnits == System.UNIT_METRIC ? currentWeatherConditions.temperature : temperatureToFarenheit(currentWeatherConditions.temperature);
        var weatherTemperatureText = localizedTemperatureValue != null ? formatTemperature(localizedTemperatureValue) + "°" : "--°";

        hourLabel.setText(hourText);
        minuteLabel.setText(minuteText);
        secondsLabel.setText(secondsText);

        dateLabel.setText(dateText);

        weatherTemperatureLabel.setText(weatherTemperatureText);

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

    function temperatureToFarenheit(temperatureC) {
        return (temperatureC.toFloat() * 9.0 / 5.0) + 32.0;
    }

    function formatTemperature(temperature) {
        var sign = temperature < 0 ? "-" : "";
        return sign + temperature.format("%i");
    }
}
