-- CreateEnum
CREATE TYPE "public"."Role" AS ENUM ('TOURIST', 'POLICE', 'TOURISM_ADMIN', 'OPERATOR');

-- CreateEnum
CREATE TYPE "public"."IdStatus" AS ENUM ('PENDING', 'ACTIVE', 'EXPIRED', 'REVOKED');

-- CreateEnum
CREATE TYPE "public"."ZoneLevel" AS ENUM ('RESTRICTED', 'HIGH_RISK', 'SAFE');

-- CreateEnum
CREATE TYPE "public"."IncidentType" AS ENUM ('SOS', 'GEOFENCE', 'INACTIVITY', 'MANUAL');

-- CreateEnum
CREATE TYPE "public"."IncidentStatus" AS ENUM ('ACTIVE', 'ACKNOWLEDGED', 'EN_ROUTE', 'RESOLVED', 'FALSE_ALARM');

-- CreateTable
CREATE TABLE "public"."users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "name" TEXT NOT NULL,
    "role" "public"."Role" NOT NULL DEFAULT 'TOURIST',
    "language" TEXT NOT NULL DEFAULT 'en',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "emergencyContacts" JSONB,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."tourist_profiles" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "blockchainAddress" TEXT,
    "idStatus" "public"."IdStatus" NOT NULL DEFAULT 'PENDING',
    "tripStart" TIMESTAMP(3),
    "tripEnd" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tourist_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."digital_ids" (
    "id" TEXT NOT NULL,
    "touristProfileId" TEXT NOT NULL,
    "dataHash" TEXT NOT NULL,
    "network" TEXT NOT NULL DEFAULT 'polygon-mumbai',
    "txHash" TEXT,
    "contractAddress" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "digital_ids_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."location_pings" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "speed" DOUBLE PRECISION,
    "accuracy" DOUBLE PRECISION,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "location_pings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."geo_zones" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "level" "public"."ZoneLevel" NOT NULL,
    "polygonGeoJSON" JSONB NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "geo_zones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."incidents" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."IncidentType" NOT NULL,
    "status" "public"."IncidentStatus" NOT NULL DEFAULT 'ACTIVE',
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "description" TEXT,
    "metadata" JSONB,
    "assignedTo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolvedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "incidents_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "public"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "tourist_profiles_userId_key" ON "public"."tourist_profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "digital_ids_touristProfileId_key" ON "public"."digital_ids"("touristProfileId");

-- CreateIndex
CREATE INDEX "location_pings_userId_timestamp_idx" ON "public"."location_pings"("userId", "timestamp");

-- CreateIndex
CREATE INDEX "incidents_userId_createdAt_idx" ON "public"."incidents"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "incidents_status_createdAt_idx" ON "public"."incidents"("status", "createdAt");

-- AddForeignKey
ALTER TABLE "public"."tourist_profiles" ADD CONSTRAINT "tourist_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."digital_ids" ADD CONSTRAINT "digital_ids_touristProfileId_fkey" FOREIGN KEY ("touristProfileId") REFERENCES "public"."tourist_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."location_pings" ADD CONSTRAINT "location_pings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."incidents" ADD CONSTRAINT "incidents_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
