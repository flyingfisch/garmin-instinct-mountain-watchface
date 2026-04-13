import Toybox.SensorHistory;
import Toybox.System;

module DataFieldService {
    function updateInsetDataField(iconDrawable, textDrawable, fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        iconDrawable.setBitmap(getSharedDataFieldIcon(fieldType));
        textDrawable.setText(formatInsetDataField(fieldType, deviceSettings, activityInfo, activityMonitorInfo));
    }

    function formatInsetDataField(fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_ALTITUDE) {
            return formatAltitude(deviceSettings);
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_HEART_RATE) {
            return formatHeartRate(activityInfo);
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_STEPS) {
            return formatSteps(activityMonitorInfo);
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_NOTIFICATIONS) {
            return formatNotificationCount(deviceSettings);
        }

        return formatBatteryDays();
    }

    function updateDataFieldBelowTime(iconDrawable, dataFieldTextDrawable, dateTextDrawable, fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_DATE) {
            iconDrawable.setVisible(false);
            dataFieldTextDrawable.setVisible(false);
            dateTextDrawable.setVisible(true);
            dateTextDrawable.setText(WatchfaceFormatting.buildDateText());
            return;
        }

        dateTextDrawable.setVisible(false);
        iconDrawable.setVisible(true);
        iconDrawable.setBitmap(getSharedDataFieldIcon(fieldType - 1));
        dataFieldTextDrawable.setVisible(true);
        dataFieldTextDrawable.setText(formatDataFieldBelowTime(fieldType, deviceSettings, activityInfo, activityMonitorInfo));
    }

    function formatDataFieldBelowTime(fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_ALTITUDE) {
            return formatAltitude(deviceSettings);
        }

        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_HEART_RATE) {
            return formatHeartRate(activityInfo);
        }

        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_BATTERY) {
            return formatBatteryDays();
        }

        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_STEPS) {
            return formatSteps(activityMonitorInfo);
        }

        if (fieldType == WatchfaceSettings.BELOW_TIME_FIELD_NOTIFICATIONS) {
            return formatNotificationCount(deviceSettings);
        }

        return WatchfaceFormatting.buildDateText();
    }

    function getSharedDataFieldIcon(fieldType) {
        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_ALTITUDE) {
            return Rez.Drawables.AltitudeIcon;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_HEART_RATE) {
            return Rez.Drawables.HeartIcon;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_STEPS) {
            return Rez.Drawables.StepsIcon;
        }

        if (fieldType == WatchfaceSettings.INSET_DATA_FIELD_NOTIFICATIONS) {
            return Rez.Drawables.NotificationsIcon;
        }

        return getBatteryIcon();
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
        return deviceSettings.notificationCount.toString();
    }

    function formatBatteryDays() {
        var systemStats = System.getSystemStats();
        if ((systemStats has :batteryInDays) && (systemStats.batteryInDays != null)) {
            return systemStats.batteryInDays.format("%i") + "d";
        }

        if ((systemStats has :battery) && (systemStats.battery != null)) {
            return systemStats.battery.format("%i") + "%";
        }

        return "--";
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
