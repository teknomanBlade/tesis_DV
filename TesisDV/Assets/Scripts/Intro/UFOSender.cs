using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOSender : MonoBehaviour
{
    [SerializeField] private IntroUFO _myUFO;

    public void SendUFO()
    {
        IntroUFO ufoInstance = Instantiate(_myUFO);
    }
}
