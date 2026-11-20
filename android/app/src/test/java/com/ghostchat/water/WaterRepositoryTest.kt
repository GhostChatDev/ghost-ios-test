package com.ghostchat.water

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant
import java.time.ZoneOffset

private class FakeStore : KeyValueStore {
    val strings = mutableMapOf<String, String>()
    val ints = mutableMapOf<String, Int>()
    override fun getString(key: String): String? = strings[key]
    override fun putString(key: String, value: String) { strings[key] = value }
    override fun getInt(key: String, default: Int): Int = ints[key] ?: default
    override fun putInt(key: String, value: Int) { ints[key] = value }
}

class WaterRepositoryTest {
    private val dayMillis = 24L * 60 * 60 * 1000
    private var now = Instant.parse("2026-11-20T12:00:00Z").toEpochMilli()

    private fun repo(store: KeyValueStore = FakeStore()) = WaterRepository(store, ZoneOffset.UTC) { now }

    @Test fun defaultGoalIs2000() {
        assertEquals(2000, repo().goal)
    }

    @Test fun addAndTotal() {
        val r = repo()
        r.add(250)
        r.add(500)
        assertEquals(750, r.totalOn(r.today()))
        assertEquals(0.375f, r.progressOn(r.today()), 0.0001f)
    }

    @Test fun progressIsCappedAtOne() {
        val r = repo()
        repeat(5) { r.add(500) }
        assertEquals(1f, r.progressOn(r.today()), 0f)
    }

    @Test fun nonPositiveAmountsAreIgnored() {
        val r = repo()
        assertFalse(r.add(0))
        assertFalse(r.add(-100))
        assertEquals(0, r.totalOn(r.today()))
    }

    @Test fun undoRemovesLatestOnly() {
        val r = repo()
        r.add(250, now - 60_000)
        r.add(500)
        assertTrue(r.undoLast())
        assertEquals(250, r.totalOn(r.today()))
        assertTrue(r.undoLast())
        assertFalse(r.undoLast())
    }

    @Test fun dataSurvivesRestart() {
        val store = FakeStore()
        val first = repo(store)
        first.add(250)
        first.setGoal(2500)
        val second = repo(store)
        assertEquals(250, second.totalOn(second.today()))
        assertEquals(2500, second.goal)
    }

    @Test fun lastSevenDays() {
        val r = repo()
        r.add(300, now - dayMillis)
        r.add(250)
        val days = r.lastDays()
        assertEquals(7, days.size)
        assertEquals(250, days.last().ml)
        assertEquals(300, days[5].ml)
        assertEquals(0, days.first().ml)
    }

    @Test fun goalIsClamped() {
        val r = repo()
        r.setGoal(1)
        assertEquals(250, r.goal)
        r.setGoal(999_999)
        assertEquals(10000, r.goal)
    }

    @Test fun corruptSavedDataIsSkipped() {
        val store = FakeStore()
        store.strings[WaterRepository.DRINKS_KEY] = "1,100,250;garbage;2,abc,300;3,200,-5"
        val r = repo(store)
        assertEquals(listOf(Drink(1, 100, 250)), WaterRepository.decode(store.strings[WaterRepository.DRINKS_KEY]))
        assertEquals(0, r.totalOn(r.today()))
    }

    @Test fun snapshotListsNewestFirst() {
        val r = repo()
        r.add(250, now - 120_000)
        r.add(500, now - 60_000)
        val s = r.snapshot()
        assertEquals(listOf(500, 250), s.drinks.map { it.ml })
        assertEquals(750, s.total)
        assertEquals(7, s.week.size)
    }
}
