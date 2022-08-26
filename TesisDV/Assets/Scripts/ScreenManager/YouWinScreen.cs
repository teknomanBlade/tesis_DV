using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class YouWinScreen : MonoBehaviour, IScreen
{
    Button[] _buttons;
    #region Events
    public delegate void OnRestartDelegate();
    public event OnRestartDelegate OnRestartEvent;
    public delegate void OnBackToMainMenuDelegate();
    public event OnBackToMainMenuDelegate OnBackToMainMenuEvent;
    #endregion
    private void Awake()
    {
        _buttons = GetComponentsInChildren<Button>();

        foreach(var button in _buttons)
        {
            button.interactable = false;
        }
    }

    public void BTN_Back()
    {
        ScreenManager.Instance.Pop();
    }

    public void Activate()
    {
        foreach(var button in _buttons)
        {
            button.interactable = true;
        }
    }

    public void Deactivate()
    {
        foreach(var button in _buttons)
        {
            button.interactable = false;
        }
    }

    public string Free()
    {
        Destroy(gameObject);
        return "WinScreen ded :c";
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            OnRestartEvent?.Invoke();
            //SceneManager.LoadScene("MainFloor_Upgrade");
        }
        if (Input.GetKeyDown(KeyCode.M))
        {
            OnBackToMainMenuEvent?.Invoke();
            //SceneManager.LoadScene(0);
        }
    }
}
