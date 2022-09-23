using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RacketManager : MonoBehaviour
{
    [SerializeField] private Racket racket;

    void Awake()
    {
        //racket.OnRacketDestroyed += RacketDestroyed;
    }

    public void ActivateRacket()
    {
        racket.gameObject.SetActive(true);
    }

    private void RacketDestroyed(bool destroyed)
    {
        this.gameObject.SetActive(!destroyed);
    }
}
