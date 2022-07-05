using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;

public class EscapeState : MonoBaseState
{
    public float healRate = .5f;
    private Player _player;
    private float _lastHealTime; 
    void Start()
    {
        _player = GameVars.Values.Player;
    }

    public override void UpdateLoop()
    {
        if (Time.time >= _lastHealTime + healRate) 
        {
            _lastHealTime = Time.time;

            //_player.Damage();
        }
    }
    
    public override IState ProcessInput()
    {
        return this;
    }
}
