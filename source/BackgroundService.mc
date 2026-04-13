import Toybox.Position;
import Toybox.Time;
import Toybox.Weather;

module BackgroundService {
    function getBackgroundBitmap(backgroundMode, clockTime) {
        if (backgroundMode == WatchfaceSettings.BACKGROUND_MODE_DAY) {
            return Rez.Drawables.MountainBackgroundDay;
        }

        if (backgroundMode == WatchfaceSettings.BACKGROUND_MODE_NIGHT) {
            return Rez.Drawables.MountainBackgroundNight;
        }

        if (isDaylight(clockTime)) {
            return Rez.Drawables.MountainBackgroundDay;
        }

        return Rez.Drawables.MountainBackgroundNight;
    }

    function isDaylight(clockTime) {
        var positionInfo = Position.getInfo();
        if ((positionInfo == null) || (positionInfo.position == null)) {
            return isFallbackDaylight(clockTime);
        }

        if (!(Weather has :getSunrise) || !(Weather has :getSunset)) {
            return isFallbackDaylight(clockTime);
        }

        var now = Time.now();
        var sunrise = Weather.getSunrise(positionInfo.position, now);
        var sunset = Weather.getSunset(positionInfo.position, now);
        if ((sunrise == null) || (sunset == null)) {
            return isFallbackDaylight(clockTime);
        }

        var nowValue = now.value();
        return (nowValue >= sunrise.value()) && (nowValue < sunset.value());
    }

    function isFallbackDaylight(clockTime) {
        return (clockTime.hour >= 6) && (clockTime.hour < 18);
    }
}
