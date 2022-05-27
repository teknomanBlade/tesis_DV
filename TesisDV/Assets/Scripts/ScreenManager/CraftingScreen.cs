using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CraftingScreen : MonoBehaviour, IScreen
{
    Button[] _buttons;

    private void Awake()
    {
        
        _buttons = GetComponentsInChildren<Button>();

        foreach(var button in _buttons)
        {
            button.interactable = false;
        }
    }

    void Start()
    {
        this.gameObject.SetActive(false);
    }

    

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            BTN_Back();
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
        return " ";
    }
}
