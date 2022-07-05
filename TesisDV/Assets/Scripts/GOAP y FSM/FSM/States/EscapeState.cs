using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;

public class EscapeState : MonoBaseState
{
    public float healRate = 3f;
    private Player _player;
    private float _lastHealTime; 
    private EnemyHealth _myHealth;
    public float movingSpeed;
    void Start()
    {
        _myHealth = GetComponent<EnemyHealth>();
        _player = GameVars.Values.Player;
    }

    public override void UpdateLoop()
    {
        if (Time.time >= _lastHealTime + healRate) 
        {
            _lastHealTime = Time.time;

            if(_myHealth.hp < 5)
            {
                _myHealth.hp++;
            }
        }

        var dir = (_player.transform.position - transform.position).normalized;
        transform.forward = dir;
        transform.position += transform.forward * movingSpeed * Time.deltaTime;
    }
    
    public override IState ProcessInput()
    {
        if(_myHealth.hp == 5)
        {
            return Transitions["AttackState"];
        }
        return this;
    }
}
