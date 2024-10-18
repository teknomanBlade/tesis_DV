using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LetterScreen : MonoBehaviour, IScreen
{
    Button[] _buttons;

    public delegate void OnCloseLetterDelegate();
    public event OnCloseLetterDelegate OnCloseLetterEvent;

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
        return "LetterScreen ded :c";
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            OnCloseLetterEvent();
            BTN_Back();
            //Cerrar carta
        }
    }
}
