// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
///https://gist.github.com/vnavascues/cde12f67ad2b9a1d256e260d19e8baae

/**
 * **** Data Conversions ****
 *
 * countryCode (bytes2)
 * --------------------
 * ISO 3166 alpha-2 codes encoded as bytes2
 * See: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
 *
 *
 * precipitationType (uint8)
 * --------------------------
 * Value    Type
 * --------------------------
 * 0        No precipitation
 * 1        Rain
 * 2        Snow
 * 3        Ice
 * 4        Mixed
 *
 *
 * weatherIcon (uint8)
 * -------------------
 * Each icon number is related with an image and a text
 * See: https://developer.accuweather.com/weather-icons
 *
 *
 * Decimals to integers (both metric & imperial units)
 * ---------------------------------------------------
 * Condition                    Conversion
 * ---------------------------------------------------
 * precipitationPast12Hours     multiplied by 100
 * precipitationPast24Hours     multiplied by 100
 * precipitationPastHour        multiplied by 100
 * pressure                     multiplied by 100
 * temperature                  multiplied by 10
 * windSpeed                    multiplied by 10
 *
 *
 * Current weather conditions units per system
 * ---------------------------------------------------
 * Condition                    imperial    metric
 * ---------------------------------------------------
 * precipitationPast12Hours     mm          in
 * precipitationPast24Hours     mm          in
 * precipitationPastHour        mm          in
 * pressure                     mb          inHg
 * temperature                  C           F
 * windSpeed                    km/h        mi/h
 *
 *
 * Other resources
 * ---------------
 * AccuWeather API docs:
 * http://apidev.accuweather.com/developers/
 *
 * Locations API Response Parameters:
 * http://apidev.accuweather.com/developers/locationAPIparameters#responseParameters
 *
 * Current Conditions API Response Parameters:
 * http://apidev.accuweather.com/developers/currentConditionsAPIParameters#responseParameters
 */
/**
 * @title A consumer contract for AccuWeather EA 'location-current-conditions' endpoint.
 * @author LinkPool
 * @notice Request the current weather conditions for the given location coordinates (i.e. latitude and longitude).
 */
contract AutoWeatherInfo is ChainlinkClient {
    /// Chainlink のStruct のRequest型にアタッチ
    using Chainlink for Chainlink.Request;
    /// requestId
    bytes32 public requestId;

    /**
     * @notice Returns the current weather conditions of a location for the given coordinates.
     * @dev Result is encoded as LocationCurrentConditionsResult (tuple). When no location is found for the given
     * coordinates 'locationKey' value is 0 (AccuWeather Locations API does not allow 0 as a location Key).
     * @param _specId the jobID.
     * @param _payment the LINK amount in Juels (i.e. 10^18 aka 1 LINK).
     * @param _lat the latitude (WGS84 standard, from -90 to 90).
     * @param _lon the longitude (WGS84 standard, from -180 to 180).
     * @param _units the measurement system ("metric" or "imperial").
     */
    function requestLocationCurrentConditions(
        bytes32 _specId,
        uint256 _payment,
        uint256 _locationKey,
        string calldata _units
    ) public {
        Chainlink.Request memory req = buildChainlinkRequest(
            _specId,
            address(this),
            this.fulfillLocationCurrentConditions.selector
        );

        req.add("endpoint", "current-conditions"); // NB: not required if it has been hardcoded in the job spec
        req.addUint("locationKey", _locationKey);
        req.add("units", _units);

        requestId = sendChainlinkRequest(req, _payment);
        /// requestId に紐づけて結果を記録
        storeRequestParams(requestId, _locationKey, "current-conditions", 0, 0, _units);
    }

    function storeRequestParams(
        bytes32 _requestId,
        uint256 _locationKey,
        string memory _endpoint,
        string memory _lat,
        string memory _lon,
        string memory _units
    ) private {
        RequestParams memory requestParams;
        requestParams.locationKey = _locationKey;
        requestParams.endpoint = _endpoint;
        requestParams.lat = _lat;
        requestParams.lon = _lon;
        requestParams.units = _units;
        requestIdRequestParams[_requestId] = requestParams;
    }
}
