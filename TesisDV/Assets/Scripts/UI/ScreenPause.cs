using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ScreenPause : MonoBehaviour, IScreen
{
    Button[] _buttons;
    Player player;
    string _result;

    private void Awake()
    {
        _buttons = GetComponentsInChildren<Button>();
        player = GameObject.Find("Player").GetComponent<Player>();
        foreach(var button in _buttons)
        {
            button.interactable = false;
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape)) //|| Input.GetKeyDown(KeyCode.P))
        {
            BTN_Back();
            player.SwitchKinematics();
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
        return _result;
    }
}
