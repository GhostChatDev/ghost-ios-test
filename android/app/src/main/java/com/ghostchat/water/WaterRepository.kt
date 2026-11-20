package com.ghostchat.water

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

/** All the water-tracking rules. Plain Kotlin, no Android classes. */
class WaterRepository(
    private val store: KeyValueStore,
    private val zone: ZoneId = ZoneId.systemDefault(),
    private val clock: () -> Long = System::currentTimeMillis,
) {
    companion object {
        const val DEFAULT_GOAL = 2000
        const val MIN_GOAL = 250
        const val MAX_GOAL = 10000
        const val DRINKS_KEY = "water.drinks"
        const val GOAL_KEY = "water.goal"

        fun encode(drinks: List<Drink>): String =
            drinks.joinToString(";") { "${it.id},${it.timeMillis},${it.ml}" }

        fun decode(text: String?): List<Drink> {
            if (text.isNullOrBlank()) return emptyList()
            return text.split(';').mapNotNull { part ->
                val f = part.split(',')
                if (f.size != 3) return@mapNotNull null
                val id = f[0].toLongOrNull()
                val time = f[1].toLongOrNull()
                val ml = f[2].toIntOrNull()
                if (id == null || time == null || ml == null || ml <= 0) null else Drink(id, time, ml)
            }
        }
    }

    private var drinks: List<Drink> = decode(store.getString(DRINKS_KEY))
    var goal: Int = store.getInt(GOAL_KEY, 0).let { if (it > 0) it else DEFAULT_GOAL }
        private set

    fun today(): LocalDate = dayOf(clock())

    fun dayOf(millis: Long): LocalDate = Instant.ofEpochMilli(millis).atZone(zone).toLocalDate()

    /** Drinks of [day], oldest first. */
    fun drinksOn(day: LocalDate): List<Drink> =
        drinks.filter { dayOf(it.timeMillis) == day }.sortedBy { it.timeMillis }

    fun totalOn(day: LocalDate): Int = drinksOn(day).sumOf { it.ml }

    fun progressOn(day: LocalDate): Float =
        minOf(1f, totalOn(day).toFloat() / maxOf(goal, 1).toFloat())

    /** Totals for the [days] days ending on [end], oldest first. */
    fun lastDays(days: Int = 7, end: LocalDate = today()): List<DayTotal> =
        (days - 1 downTo 0).map { back ->
            val day = end.minusDays(back.toLong())
            DayTotal(day, totalOn(day))
        }

    /** Adds a drink. Returns false (and changes nothing) when [ml] is not positive. */
    fun add(ml: Int, atMillis: Long = clock()): Boolean {
        if (ml <= 0) return false
        val id = (drinks.maxOfOrNull { it.id } ?: 0L) + 1L
        drinks = drinks + Drink(id, atMillis, ml)
        saveDrinks()
        return true
    }

    /** Removes the most recent drink of [day]. Returns false if there was none. */
    fun undoLast(day: LocalDate = today()): Boolean {
        val last = drinksOn(day).lastOrNull() ?: return false
        drinks = drinks.filter { it.id != last.id }
        saveDrinks()
        return true
    }

    fun setGoal(ml: Int) {
        goal = ml.coerceIn(MIN_GOAL, MAX_GOAL)
        store.putInt(GOAL_KEY, goal)
    }

    fun snapshot(): WaterUiState {
        val day = today()
        return WaterUiState(
            today = day,
            drinks = drinksOn(day).reversed(),
            total = totalOn(day),
            goal = goal,
            progress = progressOn(day),
            week = lastDays(7, day),
        )
    }

    private fun saveDrinks() {
        store.putString(DRINKS_KEY, encode(drinks))
    }
}
