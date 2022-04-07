using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Config : MonoBehaviour
{
    public Transform mainGame;

    void Start()
    {
        ScreenManager.Instance.Push(new ScreenGO(mainGame));
    }
}