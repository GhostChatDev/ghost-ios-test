package com.ghostchat.water

import java.time.LocalDate

data class Drink(val id: Long, val timeMillis: Long, val ml: Int)

data class DayTotal(val day: LocalDate, val ml: Int)

/** What the screen shows. Built by [WaterRepository.snapshot]. */
data class WaterUiState(
    val today: LocalDate,
    /** Today's drinks, newest first. */
    val drinks: List<Drink>,
    val total: Int,
    val goal: Int,
    val progress: Float,
    /** Last 7 days, oldest first. */
    val week: List<DayTotal>,
)

/** Tiny storage interface so the logic can be unit-tested without Android. */
interface KeyValueStore {
    fun getString(key: String): String?
    fun putString(key: String, value: String)
    fun getInt(key: String, default: Int): Int
    fun putInt(key: String, value: Int)
}
