import Toybox.SensorHistory;
import Toybox.System;

module InsetFieldService {
    function updateInsetField(iconDrawable, textDrawable, fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_ALTITUDE) {
            iconDrawable.setBitmap(Rez.Drawables.AltitudeIcon);
            textDrawable.setText(formatAltitude(deviceSettings));
            return;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_HEART_RATE) {
            iconDrawable.setBitmap(Rez.Drawables.HeartIcon);
            textDrawable.setText(formatHeartRate(activityInfo));
            return;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_STEPS) {
            iconDrawable.setBitmap(Rez.Drawables.StepsIcon);
            textDrawable.setText(formatSteps(activityMonitorInfo));
            return;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_NOTIFICATIONS) {
            iconDrawable.setBitmap(Rez.Drawables.NotificationsIcon);
            textDrawable.setText(formatNotificationCount(deviceSettings));
            return;
        }

        iconDrawable.setBitmap(getBatteryIcon());
        textDrawable.setText(formatBatteryDays());
    }

    function formatAltitude(deviceSettings) {
        var elevation = getLatestElevation();
        if (elevation == null) {
            return "--";
        }

        var localizedElevation = elevation.toFloat();
        if (deviceSettings.elevationUnits != System.UNIT_METRIC) {
            localizedElevation = localizedElevation * 3.28084;
        }

        return WatchfaceFormatting.formatCompactAltitude(localizedElevation);
    }

    function getLatestElevation() {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getElevationHistory)) {
            return null;
        }

        var iterator = SensorHistory.getElevationHistory({});
        var sample = iterator.next();
        if ((sample == null) || (sample.data == null)) {
            return null;
        }

        return sample.data;
    }

    function formatHeartRate(activityInfo) {
        if ((activityInfo == null) || (activityInfo.currentHeartRate == null)) {
            return "--";
        }

        return activityInfo.currentHeartRate.toString();
    }

    function formatSteps(activityMonitorInfo) {
        var steps = getStepCount(activityMonitorInfo);
        if (steps == null) {
            return "--";
        }

        return WatchfaceFormatting.formatCompactSteps(steps);
    }

    function getStepCount(activityMonitorInfo) {
        if (activityMonitorInfo == null) {
            return null;
        }

        return activityMonitorInfo.steps;
    }

    function formatNotificationCount(deviceSettings) {
        if ((deviceSettings == null) || (deviceSettings.notificationCount == null)) {
            return "--";
        }

        return deviceSettings.notificationCount.toString();
    }

    function formatBatteryDays() {
        var systemStats = System.getSystemStats();
        if ((systemStats == null) || (systemStats.batteryInDays == null)) {
            return "--";
        }

        return systemStats.batteryInDays.format("%i") + "d";
    }

    function getBatteryIcon() {
        var systemStats = System.getSystemStats();
        if ((systemStats == null) || (systemStats.battery == null)) {
            return Rez.Drawables.BatteryCriticalIcon;
        }

        var batteryPercent = systemStats.battery.toFloat();
        if (batteryPercent >= 80.0) {
            return Rez.Drawables.BatteryFullIcon;
        }

        if (batteryPercent >= 30.0) {
            return Rez.Drawables.BatteryHalfIcon;
        }

        if (batteryPercent > 5.0) {
            return Rez.Drawables.BatteryLowIcon;
        }

        return Rez.Drawables.BatteryCriticalIcon;
    }
}
