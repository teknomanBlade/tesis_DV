using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TakenState : IState
{
    private StateMachine _fsm;
    private Cat _cat;

    public TakenState(StateMachine fsm, Cat p)
    {
        _fsm = fsm;
        _cat = p;
    }

    public void OnStart()
    {
        Debug.Log("Entre a TakenState");
        _cat.EnterTakenState();
    }

    public void OnUpdate()
    {
        Debug.Log("Estoy en TakenState");
        /*if (_cat.MyOwner.enemyType == EnemyType.Dog) 
        {
            _cat.IsHeld = false;
            _cat._fsm.ChangeCatState(CatStatesEnum.RunningState);
        }*/
    }

    public void OnExit()
    {
        Debug.Log("Sali de TakenState");
    }
}