using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public enum EnemyType { Common, Melee, Tank, Dog }
public abstract class Enemy : MonoBehaviour
{
    public Coroutine SlowDebuffCoroutine;
    public Coroutine SlowDebuffFadeCoroutine;
    [SerializeField] private float _hp;
    public float HP { get { return _hp; } set { _hp = value; } }
    [SerializeField] private int _myWittsValue;
    public float _movingSpeed;
    public float _startSpeed;
    [SerializeField] private Transform _catGrabPos;
    public Collider[] allTargets; //Borrar esto y probar.
    protected CapsuleCollider _capsuleCollider;
    protected bool isAwake = false;
    public bool isDead = false;
    public EnemyType enemyType;
    #region DistanceParameters

    //Distancia a la que empieza a perseguir al Player
    public float pursueThreshold;
    //Distancia a la que deja de perseguir al Player
    public float disengageThreshold;
    //Distancia a la que empieza a atacar al Player
    public float attackThreshold;
    //Distancia a la que deja de atacar al Player pero lo sigue persiguiendo
    public float attackDisengageThreshold;
    //Distancia a la que empieza a ir hacia la trampa.
    [SerializeField] private float _trapViewRadius;
    //Distancia a la que empieza a atacar a la trampa
    public float attackTrapThreshold;

    #endregion

    protected AudioSource _as;

    public Player _player;
    public Cat _cat;

    public bool hasObjective;
    [SerializeField] private bool isSpecialAttacking = false;
    [SerializeField] private bool isAttacking = false;
    [SerializeField] private bool isStunned = false;
    [SerializeField] private bool isForceFieldRejected = false;

    public Vector3 _exitPos;
    public Vector3 trapPos;
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;
    public bool foundTrapInPath = false;
    [SerializeField] private LayerMask _trapMask;
    public Collider _currentTrapObjective; //{ get; private set; }
    private float _currentTrapObjectiveDistance = 1000f;
    public const float MAX_CURRENT_OBJECTIVE_DISTANCE = 1000;
    public StateMachine _fsm;
    public LevelManager _lm;
    private bool canBeHit = true;
    [SerializeField]
    private bool _poisonHitted;
    public bool PoisonHitted
    {
        get { return _poisonHitted; }
        set { _poisonHitted = value; }
    }
    [SerializeField] protected LineRenderer lineRenderer;

    #region Pathfinding

    public Pathfinding _pf;
    //public PathfindingManager _pfManager; Probamos usar pathfindingManager como clase estatica.
    public List<Node> Path = new List<Node>();
    public List<Transform> PathHard = new List<Transform>();
    [SerializeField] public LayerMask obstacleMask;

    #endregion

    [Header("BattleCircle AI")]
    public float protectDistance;
    public GameObject _target;
    public Vector3 _circlePos;

    #region Events

    public event Action<bool> onWalk = delegate { };
    public event Action<bool> onForceFieldRejection = delegate { };
    public event Action<bool> onStun = delegate { };
    public event Action<bool> onCatGrab = delegate { };
    public event Action onDeath = delegate { };
    public event Action onHit = delegate { };
    public event Action onPoisonHit = delegate { };
    public event Action onPoisonHitStop = delegate { };
    public event Action onPepperHit = delegate { };
    public event Action onPaintballHit = delegate { };
    public event Action onElectricHit = delegate { };
    public event Action<bool> onAttack = delegate { };
    public event Action<bool> onAttackSpecial = delegate { };
    public event Action onDisolve = delegate { };
    public event Action onEndSpawn = delegate { };
    public event Action<Enemy> onStatsEnhanced = delegate { };

    public delegate void OnDoorInteractDelegate();
    public event OnDoorInteractDelegate OnDoorInteract;
    #endregion Events

    public void ActiveGrayAttackRingCollider()
    {
        transform.GetComponentInChildren<GrayAttackRing>().EnableBoxCollider();
    }

    public void TakeDamage(float DamageAmount)
    {
        _hp -= DamageAmount;
        GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);

        if (_hp > 0)
        {
            if (canBeHit)
            {
                if (PoisonHitted)
                {
                    onPoisonHit();
                }
                else 
                {
                    onHit();
                }
            }
        }
        else
        {
            isAwake = false;
            AIManager.Instance.RemoveEnemyFromList(this, hasObjective);
            if (hasObjective)
            {
                Debug.Log("LLEGA A DROP CAT: " + gameObject.name);
                DropCat();
            }

            isDead = true;
            if (gameObject.tag.Equals("Tutorial"))
                GameVars.Values.ShowNotification("You gain the Wit resource by knocking down Enemies. As you can see at the right upper corner.");

            //SendWitts();
            _capsuleCollider.enabled = false;
            GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
            onDeath();
            _lm.RemoveGray(this);

            //_navMeshAgent.speed = 0; //Se va el navmesh

            //Desabilitar colliders y lo que haga falta.
        }
    }

    public void DetectTraps()
    {
        allTargets = Physics.OverlapSphere(transform.position, _trapViewRadius, _trapMask);

        if (allTargets.Length == 0 || _currentTrapObjective == null || !_currentTrapObjective.GetComponent<Trap>().active)
        {
            _currentTrapObjective = null;
            _currentTrapObjectiveDistance = MAX_CURRENT_OBJECTIVE_DISTANCE;
        }

        if (_currentTrapObjective == null || !_currentTrapObjective.GetComponent<Trap>().active || _currentTrapObjectiveDistance > _trapViewRadius)
        {

            foreach (var item in allTargets)
            {
                RaycastHit hit;
                Vector3 dir = item.transform.position - transform.position;
                //Ahora usamos obstacleMask                                                           
                if (Vector3.Distance(transform.position, item.transform.position) < _currentTrapObjectiveDistance && item.GetComponent<Trap>() && !Physics.Raycast(transform.position, dir, out hit, dir.magnitude, obstacleMask))//GameVars.Values.GetWallLayerMask()))
                {
                    var trap = item.GetComponent<Trap>();

                    if (trap && item.GetComponent<Trap>().active)
                    {
                        if (item.GetComponent<ForceField>())
                        {
                            RaycastHit forceFieldHit;
                            Physics.Raycast(transform.position, dir, out forceFieldHit, Mathf.Infinity, GameVars.Values.GetItemLayerMask());
                            _currentTrapObjectiveDistance = forceFieldHit.distance;
                            _currentTrapObjective = item;
                        }
                        else
                        {
                            _currentTrapObjectiveDistance = Vector3.Distance(transform.position, item.transform.position);
                            _currentTrapObjective = item;
                        }

                    }
                }
            }
        }

        if (_currentTrapObjectiveDistance < _trapViewRadius && _currentTrapObjective != null && _currentTrapObjective.GetComponent<Trap>().active)
        {
            foundTrapInPath = true;
        }
    }

    public void DetectForceFields()
    {
        allTargets = Physics.OverlapSphere(transform.position, _trapViewRadius, _trapMask);

        if (allTargets.Length == 0 || _currentTrapObjective == null || !_currentTrapObjective.GetComponent<Trap>().active)
        {
            _currentTrapObjective = null;
            _currentTrapObjectiveDistance = MAX_CURRENT_OBJECTIVE_DISTANCE;
        }

        if (_currentTrapObjective == null || !_currentTrapObjective.GetComponent<Trap>().active || _currentTrapObjectiveDistance > _trapViewRadius)
        {
            foreach (var item in allTargets)
            {
                RaycastHit hit;
                Vector3 dir = item.transform.position - transform.position;
                //Ahora usamos obstacleMask                                                           
                if (Vector3.Distance(transform.position, item.transform.position) < _currentTrapObjectiveDistance && item.GetComponent<Trap>() && !Physics.Raycast(transform.position, dir, out hit, dir.magnitude, obstacleMask))//GameVars.Values.GetWallLayerMask()))
                {
                    var trap = item.GetComponent<Trap>();

                    if (trap && item.GetComponent<Trap>().active)
                    {
                        if (item.GetComponent<ForceField>())
                        {
                            RaycastHit forceFieldHit;
                            Physics.Raycast(transform.position, dir, out forceFieldHit, Mathf.Infinity, GameVars.Values.GetItemLayerMask());
                            _currentTrapObjectiveDistance = forceFieldHit.distance;
                            _currentTrapObjective = item;
                            foundTrapInPath = true;

                        }
                    }
                }
            }
        }

        if (_currentTrapObjectiveDistance < _trapViewRadius && _currentTrapObjective != null && _currentTrapObjective.GetComponent<Trap>().active)
        {
            foundTrapInPath = true;
        }
    }


    public void ForceFieldRejection()
    {
        Debug.Log("LLEGA A FORCEFIELD REJECTION");
        if (!isForceFieldRejected)
        {
            Debug.Log("LLEGA A FORCEFIELD REJECTION IF " + isForceFieldRejected);
            onForceFieldRejection(!isForceFieldRejected);
            onWalk(isForceFieldRejected);
            isForceFieldRejected = true;
        }
    }

    public void Stun(float time, bool stunned)
    {
        StartCoroutine(StunCycle(time, stunned));
    }

    IEnumerator StunCycle(float time, bool stunned) 
    {
        Debug.Log("STUNEA AL GRIS");
        onStun(stunned);
        onWalk(!stunned);
        _movingSpeed = 0f;
        isStunned = stunned;
        yield return new WaitForSeconds(time);
        isStunned = false;
        onStun(isStunned);
        onWalk(!isStunned);
        _movingSpeed = _startSpeed;
    }

    public void AttackPlayer() //Verifica que no estemos atacando para mirar hacia el jugador y envia nuevamente la animacion de ataque. El booleano se resetea con un AnimEvent.
    {
        if (!isAttacking)
        {
            var dir = _player.transform.position - transform.position;
            Vector3 aux = dir;
            dir = new Vector3(aux.x, 0f, aux.z);
            transform.forward = dir;
            //_navMeshAgent.speed = 0; //Se va el navmesh
            onWalk(isAttacking);
            onAttack(!isAttacking);
            isAttacking = true;
        }

    }

    public void AttackTrap()
    {
        if (!isSpecialAttacking)
        {
            canBeHit = false;
            var dir = _currentTrapObjective.transform.position - transform.position;
            transform.forward = dir;
            //_navMeshAgent.speed = 0; //Se va el navmesh
            onWalk(isSpecialAttacking);
            onAttackSpecial(!isSpecialAttacking);
            //onAttack(!isAttacking);
            isSpecialAttacking = true;
            //_currentTrapObjective.GetComponent<BaseballLauncher>().Inactive();
        }
        if (_currentTrapObjective.GetComponent<Trap>() && _currentTrapObjective.GetComponent<Trap>().active == false)
        {
            foundTrapInPath = false;

            //canBeHit = true;
            RevertSpecialAttackBool();
        }
        /* if(_currentTrapObjective.GetComponent<NailFiringMachine>() && _currentTrapObjective.GetComponent<NailFiringMachine>().active == false)
            foundTrapInPath = false;
            canBeHit = true;
        } */
    }

    public void RevertSpecialAttackBool() //Esto se llama por la animación de ataque.
    {
        isSpecialAttacking = false;
        //foundTrapInPath = false;
        onAttackSpecial(isSpecialAttacking);
        //_navMeshAgent.speed = 1; //Se va el navmesh
        onWalk(!isSpecialAttacking);
        //_currentTrapObjectiveDistance = MAX_CURRENT_OBJECTIVE_DISTANCE;
        Debug.Log("Chau chau");
        //_fsm.ChangeState(EnemyStatesEnum.CatState);
    }

    public void RevertAttackBool() //Esto se llama por la animación de ataque.
    {
        isAttacking = false;
        onAttack(isAttacking);
        //_navMeshAgent.speed = 1; //Se va el navmesh
        onWalk(!isAttacking);
    }

    public void RevertForceFieldRejectBool() //Esto se llama por la animación de ataque.
    {
        isForceFieldRejected = false;
        onForceFieldRejection(isForceFieldRejected);
        //_navMeshAgent.speed = 1; //Se va el navmesh
        onWalk(!isForceFieldRejected);
    }

    public void GrabCat()
    {
        //GetNearestUFO(); Cuesta conseguir el Exit pos y despues escapar, despues lo arreglo.
        ReduceSpeed();
        AIManager.Instance.SetNewTarget(this.gameObject);
        onCatGrab(true);
        GameVars.Values.TakeCat(_exitPos, this); //Todo esto se hace en una corrutina para darle tiempo al Gray a encontrar la nave mas cercana.
        hasObjective = true;
        _lm.CheckForObjective();

        GetNearestUFO();
        //StartCoroutine("GrabCatCoroutine");
    }

    public void EscapeWithCat()
    {
        if(_lm.objective != null)
            _lm.objective.transform.position = _catGrabPos.transform.position;
    }

    public void DropCat()
    {
        hasObjective = false;
        GameVars.Values.SetCatFree();
        _lm.CheckForObjective();
    }

    private void GetNearestUFO() //Hasta solucionarlo no se usa. Probar corrutina.
    {
        float currentDistance = 99999;
        Vector3 currentExitPos = _exitPos;

        foreach (UFO ufo in _lm.AllUFOs)
        {
            if (Vector3.Distance(transform.position, ufo.transform.position) < currentDistance)
            {
                currentDistance = Vector3.Distance(transform.position, ufo.transform.position);
                currentExitPos = ufo.transform.position;
            }

        }

        Vector3 aux = currentExitPos;
        _exitPos = new Vector3(aux.x, 0f, aux.z);
        //_fsm.ChangeState(EnemyStatesEnum.EscapeState); 
    }

    public Vector3 GetPlayerPos()
    {
        Vector3 aux = _player.transform.position;
        Vector3 objective = new Vector3(aux.x, 0f, aux.z);

        return objective;
    }

    public void GoBackToShip()
    {
        AIManager.Instance.RemoveEnemyFromList(this, hasObjective);
        _lm.RemoveGray(this);
        SendWitts();
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        //_lm.RemoveGray(this);
        //miniMap.RemoveGray(this);

        Destroy(gameObject);
    }

    /*public void GetDoor(Door door)
    {
        OpenDoor(door);
    }

    private void OpenDoor(Door door)
    {
        door.IsLocked = false;
        door.EnemyInteractionCheck(true);
        door.Interact();
        GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(door.itemName));
    }*/

    public void DoorInteract() 
    {
        OnDoorInteract();
    }

    public void SendWitts()
    {
        //onWitGainEffect();
        GameVars.Values.Inventory.ReceiveWitts(_myWittsValue);
    }

    public void Dissolve()
    {
        onDisolve();
    }

    public void PepperHit() 
    {
        onPepperHit();
    }

    public void ElectricDebuffHit()
    {
        onElectricHit();
    }
    public void PaintballHit()
    {
        onPaintballHit();
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
        Invoke(nameof(ChangePoisonState), 4f);
        _movingSpeed -= slowAmount;
    }

    public void ChangePoisonState() 
    {
        PoisonHitted = false;
        onPoisonHitStop();
    }

    public void SlowDebuffFade()
    {
        SlowDebuffFadeCoroutine = StartCoroutine(SlowDebuffFadeActive());
    }

    IEnumerator SlowDebuffFadeActive()
    {
        yield return new WaitForSeconds(6f);
        _movingSpeed = _startSpeed;
    }

    public void SlowDebuff(float slowAmount) 
    {
        SlowDebuffCoroutine = StartCoroutine(SlowDebuffActive(slowAmount));
    }

    IEnumerator SlowDebuffActive(float slowAmount) 
    {
        _movingSpeed -= slowAmount;
        yield return new WaitForSeconds(2f);
        _movingSpeed = _startSpeed;
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

    public Enemy SetName(string name)
    {
        gameObject.name += name;
        return this;
    }
    public Enemy SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);

        return this;
    }

    public float GetVelocity()
    {
        //return _navMeshAgent.velocity; //Se va el navmesh
        return _movingSpeed;
    }

    public void ReduceSpeed()
    {
        //_navMeshAgent.speed *= 0.4f; //Se va el navmesh
        if(enemyType != EnemyType.Dog)
            _movingSpeed *= 0.4f;
    }

    public void GetProtectTarget()
    {
        _target = AIManager.Instance.currentTarget;
    }

    public void ReferenceEvent(bool value)
    {
        if (enemyType != EnemyType.Dog)
        {
            onWalk(value);
        }
        else
        {
            OnSpecialChildEvent();
        }

        onEndSpawn();
    }

    public virtual void OnSpecialChildEvent() 
    {
        
    }

    public void SetPath(List<Node> nodos) //esto no hace falta, es para testear.
    {
        Path = null;
        Path = nodos;
    }

    public void SetPathHard(List<Transform> nodos) //esto no hace falta, es para testear.
    {
        Path = null;
        PathHard = nodos;
    }

    public Enemy SetSpawnPos(Vector3 newPos)
    {
        transform.position = newPos;
        return this;
    }
    public Enemy SetStatsEnhanced() 
    {
        onStatsEnhanced(this);
        return this;
    }
    public int GetCurrentWaypoint()
    {
        return _currentWaypoint;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, protectDistance);
    }

}
