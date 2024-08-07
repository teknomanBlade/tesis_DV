using UnityEngine;
using System;
using FSM;

public class BreakObjectState : MonoBaseState
{
    private Player _player;
    public float attackRate = .5f;
    public float _playerDistance;
    private float _attackThreshold = 2.5f;
    private float _lastAttackTime; 
    private EnemyHealth _myHealth;

    void Start()
    {
        _player = GameVars.Values.Player;
        _myHealth = GetComponent<EnemyHealth>();
    }

    public override void UpdateLoop()
    {
        Debug.Log("Ataco la puerta");

        _myHealth.SetPosition(transform.position);
        if (Time.time >= _lastAttackTime + attackRate) 
        {
            _lastAttackTime = Time.time;
            _player.Damage();
        }
    }

     public override IState ProcessInput()
    {
        _playerDistance = Vector3.Distance(_player.transform.position, transform.position);

        if(_playerDistance >= _attackThreshold)
        {        
            return Transitions["OnChaseState"];
        }
        if(_myHealth.hp <= 1)
        {
            return Transitions["OnEscapeState"];
        }
        return this;
    }
}
