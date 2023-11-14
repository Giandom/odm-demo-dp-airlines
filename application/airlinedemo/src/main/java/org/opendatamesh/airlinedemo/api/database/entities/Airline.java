package org.opendatamesh.airlinedemo.api.database.entities;


import jakarta.persistence.*;
import org.opendatamesh.airlinedemo.api.resources.V1.AirlineResource;

@Entity
@Table(name = "Airline")
@IdClass(AirlineResource.class)
public class Airline {

    @Id
    @Column(name = "airline_code")
    private String airlineCode;

    @Id
    @Column(name = "apt_org")
    private String aptOrg;

    @Id
    @Column(name = "apt_dst")
    private String aptDst;

    @Column(name = "flt_freq")
    private Integer fltFreq;

    public Airline() {
    }

    public Airline(String airlineCode, String aptOrg, String aptDst, Integer fltFreq) {
        this.airlineCode = airlineCode;
        this.aptOrg = aptOrg;
        this.aptDst = aptDst;
        this.fltFreq = fltFreq;
    }

    public String getAirlineCode() {
        return airlineCode;
    }

    public void setAirlineCode(String airlineCode) {
        this.airlineCode = airlineCode;
    }

    public String getAptOrg() {
        return aptOrg;
    }

    public void setAptOrg(String aptOrg) {
        this.aptOrg = aptOrg;
    }

    public String getAptDst() {
        return aptDst;
    }

    public void setAptDst(String aptDst) {
        this.aptDst = aptDst;
    }

    public Integer getFltFreq() {
        return fltFreq;
    }

    public void setFltFreq(Integer fltFreq) {
        this.fltFreq = fltFreq;
    }
}
