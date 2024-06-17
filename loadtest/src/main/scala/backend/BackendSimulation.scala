package backend

import io.gatling.core.scenario.Simulation
import io.gatling.core.Predef._
import io.gatling.http.Predef._

import scala.concurrent.duration._

class BackendSimulation extends Simulation {

  object Constants {
    val getAllStatesRequestPerSecond: Int = System.getProperty("getAllStatesRequestPerSecond").toInt
    val durationRampUp: FiniteDuration = System.getProperty("durationRampUpSeconds").toInt.seconds
    val durationSeconds: FiniteDuration = System.getProperty("durationSeconds").toInt.seconds
    val url: String = System.getProperty("url")
    val proxyHost: String = System.getProperty("proxyHost")
    val proxyPort: String = System.getProperty("proxyPort")
    val proxyUser: String = System.getProperty("proxyUser")
    val proxyPassword: String = System.getProperty("proxyPassword")
    val getAllStatesRequestGroup: String = "Get all states"

  }

  val httpConf = if (Constants.proxyHost == null || Constants.proxyHost == "" || Constants.proxyPort == null || Constants.proxyPort == ""
    || Constants.proxyUser == null || Constants.proxyUser == "" || Constants.proxyPassword == null || Constants.proxyPassword == "")
    http
      .disableCaching
      .connectionHeader("keep-alive")
      .shareConnections
  else
    http
      .disableCaching
      .connectionHeader("keep-alive")
      .shareConnectionsó
      .proxy(Proxy(Constants.proxyHost, Constants.proxyPort.toInt).credentials(Constants.proxyUser, Constants.proxyPassword))

  val getAllStatesRequest = scenario("getAllStatesRequest").repeat(1) {
    group(Constants.getAllStatesRequestGroup) {
      exec(http("getAllStatesRequest_metrics")
        .get(Constants.url + "/device/v1/test")
        .header("Content-Type", "application/json")
        .header("Authorization", "Basic dGVzdFVzZXI6d2VsdA==")
        .header("Accept", "application/json")
        .check(status.in(200, 202))
      ).pause(1)
    }
  }

  setUp(
    getAllStatesRequest.inject(
      rampUsersPerSec(0) to (Constants.getAllStatesRequestPerSecond) during (Constants.durationRampUp),
      constantUsersPerSec(Constants.getAllStatesRequestPerSecond) during (Constants.durationSeconds)).protocols(httpConf)
  )
}