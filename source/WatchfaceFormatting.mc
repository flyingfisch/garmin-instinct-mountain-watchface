import Toybox.System;
import Toybox.Time;
import Toybox.Weather;

module WatchfaceFormatting {
    function formatHour(clockTime, is24Hour, showLeadingHourZero) {
        var displayHour = clockTime.hour;
        if (!is24Hour) {
            displayHour = displayHour % 12;

            if (displayHour == 0) {
                displayHour = 12;
            }
        }

        var hourText = displayHour.toString();
        if (showLeadingHourZero && (displayHour < 10)) {
            hourText = "0" + hourText;
        }

        return hourText;
    }

    function formatMinute(clockTime) {
        return clockTime.min.format("%02d");
    }

    function formatSeconds(clockTime) {
        return clockTime.sec.format("%02d");
    }

    function shouldShowSeconds(secondsMode, isAwake) {
        if (secondsMode == WatchfaceSettings.SECONDS_MODE_ON) {
            return true;
        }

        if (secondsMode == WatchfaceSettings.SECONDS_MODE_WRIST_TURN) {
            return isAwake;
        }

        return false;
    }

    function buildDateText() {
        var currentDate = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthText = normalizeMonthCase(currentDate.month.toString());
        var dayText = currentDate.day.toString();

        return monthText + " " + dayText;
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

    function getWeatherTemperatureText(deviceSettings) {
        var currentWeatherConditions = Weather.getCurrentConditions();
        if ((currentWeatherConditions == null) || (currentWeatherConditions.temperature == null)) {
            return "--\u00B0";
        }

        var localizedTemperatureValue = currentWeatherConditions.temperature;
        if (deviceSettings.temperatureUnits != System.UNIT_METRIC) {
            localizedTemperatureValue = temperatureToFahrenheit(localizedTemperatureValue);
        }

        return formatTemperature(localizedTemperatureValue) + "\u00B0";
    }

    function temperatureToFahrenheit(temperatureC) {
        return (temperatureC.toFloat() * 9.0 / 5.0) + 32.0;
    }

    function formatTemperature(temperature) {
        return temperature.format("%i");
    }

    function formatCompactAltitude(altitude) {
        var altitudeValue = altitude.toFloat();
        if (altitudeValue < 0.0) {
            altitudeValue = 0.0;
        }

        if (altitudeValue < 1000.0) {
            return altitudeValue.format("%i");
        }

        var altitudeInThousands = altitudeValue / 1000.0;
        return altitudeInThousands.format("%i") + "k";
    }

    function formatCompactSteps(steps) {
        var stepValue = steps.toFloat();
        if (stepValue < 1000.0) {
            return stepValue.format("%i");
        }

        var stepsInThousands = stepValue / 1000.0;
        var formattedThousands = stepsInThousands.format("%.1f");
        if (formattedThousands.substring(formattedThousands.length() - 2, formattedThousands.length()) == ".0") {
            formattedThousands = formattedThousands.substring(0, formattedThousands.length() - 2);
        }

        return formattedThousands + "k";
    }
}
