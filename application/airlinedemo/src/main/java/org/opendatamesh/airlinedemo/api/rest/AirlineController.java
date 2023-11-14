package org.opendatamesh.airlinedemo.api.rest;

import jakarta.validation.Valid;
import org.opendatamesh.airlinedemo.api.database.entities.Airline;
import org.opendatamesh.airlinedemo.api.database.repositories.AirlineRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/airline")
@Validated
public class AirlineController {

    private static final Logger logger = LoggerFactory.getLogger(AirlineController.class);

    @Autowired
    private AirlineRepository airlineRepository;

    @GetMapping("/getAirlines")
    @ResponseStatus(HttpStatus.OK)
    public List<String> getAirlines() {
        return airlineRepository.findDistinctByAirlineCode();
    }

    @GetMapping("/{airline_code}/getTop3FrequentFlights")
    @ResponseStatus(HttpStatus.OK)
    public List<Airline> getTop3FrequentFlights(@Valid @PathVariable(value = "airline_code", required = true) String airline_code) {
        return airlineRepository.findTop3ByAirlineCodeOrderByFltFreqDesc(airline_code);
    }

}