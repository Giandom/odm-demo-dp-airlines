package org.opendatamesh.airlinedemo.api.resources.V1;


import jakarta.validation.constraints.NotNull;

public class AirlineResource {
    @NotNull
    private String airlineCode;

    @NotNull
    private String aptOrg;

    @NotNull
    private String aptDst;

    @NotNull
    private Integer fltFreq;

    public AirlineResource(){}


    public AirlineResource(String airlineCode, String aptOrg, String aptDst, Integer fltFreq) {
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
