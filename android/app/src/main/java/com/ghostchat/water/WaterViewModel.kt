package com.ghostchat.water

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class WaterViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = WaterRepository(SharedPrefsStore(application))
    private val _state = MutableStateFlow(repository.snapshot())
    val state: StateFlow<WaterUiState> = _state.asStateFlow()

    fun add(ml: Int) {
        repository.add(ml)
        refresh()
    }

    fun undo() {
        repository.undoLast()
        refresh()
    }

    fun changeGoal(delta: Int) {
        repository.setGoal(repository.goal + delta)
        refresh()
    }

    /** Call when the app comes back to the front: the day may have changed. */
    fun refresh() {
        _state.value = repository.snapshot()
    }
}
