using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public abstract class Enemy : MonoBehaviour
{
    [SerializeField] private int _hp;
    [SerializeField] private float _movingSpeed;
    [SerializeField] private Transform _catGrabPos;

    protected bool isAwake = false;
    public bool isDead = false;

    #region DistanceParameters

    //Distancia a la que empieza a perseguir al Player
    public float pursueThreshold;
    //Distancia a la que deja de perseguir al Player
    public float disengageThreshold;
    //Distancia a la que empieza a atacar al Player
    public float attackThreshold;
    //Distancia a la que deja de atacar al Player pero lo sigue persiguiendo
    public float attackDisengageThreshold;
    //Distancia a la que empieza a atacar a la trampa
    public float attackTrapThreshold;

    #endregion

    protected AudioSource _as;

    public Player _player;
    public Cat _cat;

    public bool hasObjective;
    [SerializeField] private bool isAttacking = false;

    public Vector3 _exitPos;
    public Vector3 trapPos;

    protected NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;
    private bool pathIsCreated;
    private bool canCreatePath;
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;

    public bool foundTrapInPath = false;
    [SerializeField] private float _trapViewRadius;
    [SerializeField] private LayerMask _trapMask;
    public Collider _currentTrapObjective { get; private set; }
    private float _currentTrapObjectiveDistance = 1000f;
    public const float MAX_CURRENT_OBJECTIVE_DISTANCE = 1000;

    public LevelManager _lm;
    [SerializeField] protected LineRenderer lineRenderer;

    #region Events

    public event Action<bool> onWalk = delegate { };
    public event Action<bool> onCatGrab = delegate { };
    public event Action onDeath = delegate { };
    public event Action onHit = delegate { };
    public event Action<bool> onAttack = delegate { };
    public event Action onDisolve = delegate { };
    public event Action onEndSpawn = delegate { };

    #endregion Events

    public void TakeDamage(int DamageAmount)
    {
        _hp -= DamageAmount;
        GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
        
        if(_hp > 0)
        {
            onHit();
        }
        else
        {
            isAwake= false;
            isDead = true;
            GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
            onDeath();
            _lm.RemoveGray(this);
            if(hasObjective)
            {
                DropCat();
            }
            _navMeshAgent.speed = 0;
            //Desabilitar colliders y lo que haga falta.
        }
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        if (NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            pathIsCreated = true;
            DrawLineRenderer(path.corners);  
        }
    }

    public void ResetPathAndSetObjective(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        CalculatePath(targetPosition);  
        //CalculatePath(currentObjective.transform.position);
        _currentWaypoint = 0;
        pathIsCreated = false;
    }

    public void Move()
    {
        if (pathIsCreated) //Probar sin bool. No funciona, entra a Move cuando el waypoint todavia no tiene valor asignado.
        {
            onWalk(true); //Esta llamada de evento no funciona por el NavMeshAgent.
            Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * _movingSpeed * Time.deltaTime;
            Debug.Log(dir.magnitude);
            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos despu�s de verificar.
                if (_currentWaypoint + 1 > _waypoints.Length) //-1
                {
                    //canCreatePath = true; probar con ResetAndSet directo.
                    //ResetPathAndSetObjective(); Se resetea en los states ahora.
                    //Debug.Log("Reseted");
                    
                        
                    
                    //_currentWaypoint = 0; Reseteamos el current waypoint en la funcion de arriba ^_^                   
                }
                else
                {
                    _currentWaypoint++;
                }

            }
            
        }
    }

    public void DetectTraps()
    {
       
        Collider[] allTargets = Physics.OverlapSphere(transform.position, _trapViewRadius, _trapMask);

        if (allTargets.Length == 0 || _currentTrapObjective == null)
        {
            _currentTrapObjective = null;
            _currentTrapObjectiveDistance = MAX_CURRENT_OBJECTIVE_DISTANCE;
        }

        if (_currentTrapObjective == null || !_currentTrapObjective.GetComponent<BaseballLauncher>().active || _currentTrapObjectiveDistance > _trapViewRadius) //cambiar el baseballLauncher por clase padre de trampas.
        {
            
            foreach (var item in allTargets)
            {
                
                if (Vector3.Distance(transform.position, item.transform.position) < _currentTrapObjectiveDistance && item.GetComponent<BaseballLauncher>())
                {
                    if (item.GetComponent<BaseballLauncher>().active) //cambiar el baseballLauncher por clase padre de trampas.
                    {
                        _currentTrapObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
                        _currentTrapObjective = item;
                        
                    }
                }
            }
            
        }

        if (_currentTrapObjectiveDistance < _trapViewRadius && _currentTrapObjective != null)
        {
            foundTrapInPath = true;
        }
        
    }

    public void AttackPlayer() //Verifica que no estemos atacando para mirar hacia el jugador y envia nuevamente la animacion de ataque. El booleano se resetea con un AnimEvent.
    {
        if(!isAttacking)
        {
            var dir = _player.transform.position - transform.position;
            transform.forward = dir;
            _navMeshAgent.speed = 0;
            onWalk(isAttacking);
            onAttack(!isAttacking);
            isAttacking = true; 
        }
       
    }

    public void AttackTrap()
    {
        if(!isAttacking)
        {
            var dir = _currentTrapObjective.transform.position - transform.position;
            transform.forward = dir;
            _navMeshAgent.speed = 0;
            onWalk(isAttacking);
            onAttack(!isAttacking);
            isAttacking = true; 
        }
        if(!_currentTrapObjective.GetComponent<BaseballLauncher>().active) //cambiar el baseballLauncher por clase padre de trampas.
        {
            foundTrapInPath = false;
        }
    }

    public void RevertAttackBool() //Esto se llama por la animación de ataque.
    {
        onAttack(!isAttacking);
        _navMeshAgent.speed = 1;
        onWalk(isAttacking);
        isAttacking = false;   
    }

    public void GrabCat()
    {
        //GetNearestUFO(); Cuesta conseguir el Exit pos y despues escapar, despues lo arreglo.
        //_anim.SetBool("IsGrab", true); Ahora se usa el evento de abajo.
        onCatGrab(true);
        GameVars.Values.TakeCat(_exitPos);
        hasObjective = true;
        _lm.CheckForObjective();
    }

    public void EscapeWithCat()
    {
        _lm.objective.transform.position = _catGrabPos.transform.position;
    }

    public void DropCat()
    {
        hasObjective = false;
        GameVars.Values.SetCatFree();
        _lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        _lm.RemoveGray(this);

        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        //_lm.RemoveGray(this);
        //miniMap.RemoveGray(this);

        Destroy(gameObject);
    }

    public void Dissolve()
    {
        onDisolve();
    }

    public void AwakeGray()
    {
        isAwake = true;
    }

    public void EndSpawnAnim()
    {
        onEndSpawn();
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public void SlowDown(float slowAmount)
    {
        _navMeshAgent.speed -= slowAmount;
    }   

    private void DrawLineRenderer(Vector3[] waypoints)  //Esto deberia ir en el view T.T Apenas este todo bien lindo lo cambio
    {
        lineRenderer.positionCount = waypoints.Length;
        lineRenderer.SetPosition(0, waypoints[0]);

        for (int i = 1; i < waypoints.Length; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].x, waypoints[i].y, waypoints[i].z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

    public Enemy SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);

        return this;
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
    }

    public void ReferenceEvent(bool value)
    {
        onWalk(value);
    }

}