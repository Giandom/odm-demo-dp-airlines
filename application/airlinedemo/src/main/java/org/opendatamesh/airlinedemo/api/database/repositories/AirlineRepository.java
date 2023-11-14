package org.opendatamesh.airlinedemo.api.database.repositories;

import org.opendatamesh.airlinedemo.api.database.entities.Airline;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface AirlineRepository extends CrudRepository<Airline, Long> {
    public List<Airline> findTop3ByAirlineCodeOrderByFltFreqDesc(String airlineCode);

    @Query("select distinct airlineCode from Airline")
    public List<String> findDistinctByAirlineCode();
}
