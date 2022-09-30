using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOLandingIndicator : MonoBehaviour
{
    private GameObject _myLR;

    void Start()
    {
        _myLR = transform.GetChild(0).gameObject;
    }

    public void DisableLineRenderer()
    {
        _myLR.SetActive(false);
    }
}
